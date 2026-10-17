/// A utility library that enhances [EventSink] instances with safe error emission
/// capabilities, ensuring robust error handling in reactive architectures.
library;

import 'dart:async';

/// A resilient boundary proxy that shields upstream event producers from asynchronous
/// sink teardown failures when dispatching errors.
///
/// In complex, highly concurrent systems, an upstream error handler often lacks
/// perfectly synchronized knowledge of a downstream [EventSink]'s exact lifecycle state.
/// For example, if a background task attempts to push an exception payload to a
/// [StreamController] that a different subsystem concurrently closed due to a timeout,
/// standard Dart streams will throw an aggressive, unhandled [StateError] that crashes
/// the entire isolate.
///
/// This extension resolves this by establishing a defensive emission boundary.
/// It introduces a "try-add-error" paradigm, absorbing expected lifecycle exceptions
/// (like adding to a closed sink) to maintain pipeline stability without
/// requiring defensive `isClosed` checks everywhere in the codebase.
extension OnEventSink<T> on EventSink<T> {
  /// Attempts to safely broadcast an [error] to this sink without throwing
  /// a [StateError] if the sink has already been closed.
  ///
  /// This method provides specialized, performant fast-paths for [StreamController]
  /// instances by evaluating their [StreamController.isClosed] property directly.
  /// For other [EventSink] implementations that do not expose such state, it
  /// attempts to add the error and gracefully catches and ignores any resulting [StateError].
  ///
  /// The [error] parameter represents the primary exception or error payload to be
  /// dispatched to downstream listeners.
  ///
  /// The optional [stackTrace] can accompany the [error] to preserve the
  /// execution context where the failure originally occurred.
  ///
  /// If [ignoreError] is `true`, any non-[StateError] exceptions encountered
  /// during the internal process of adding the [error] to the sink will be silently
  /// caught, preventing unexpected crashes during cleanup or teardown phases. If `false`
  /// (the default), such exceptions are rethrown.
  ///
  /// The [onError] callback provides a mechanism to monitor or log any internal
  /// exceptions (along with their [StackTrace]) that arise specifically from the act
  /// of dispatching the original [error] into the sink. This is especially useful when
  /// [ignoreError] is `true`, allowing these swallowed exceptions to still be tracked
  /// and recorded without crashing the active zone.
  ///
  /// ```dart
  /// final controller = StreamController<String>();
  ///
  /// // Safely emit an error. This avoids crashes even if the controller
  /// // was concurrently closed in a different part of the system.
  /// controller.tryAddError(
  ///   FormatException('Invalid input data'),
  ///   ignoreError: true,
  ///   onError: (internalErr, st) => print('Failed to broadcast error: $internalErr'),
  /// );
  /// ```
  void tryAddError(
    Object error, {
    StackTrace? stackTrace,
    bool ignoreError = false,
    void Function(Object error, StackTrace stackTrace)? onError,
  }) {
    final self = this;
    if (self is StreamController<T>) {
      if (!self.isClosed) {
        if (ignoreError) {
          try {
            self.addError(error, stackTrace);
          } catch (e, st) {
            onError?.call(e, st);
          }
        } else {
          self.addError(error, stackTrace);
        }
      }
    } else {
      try {
        addError(error, stackTrace);
      } on StateError {
        // Ignore StateError, which typically means the sink is closed
      } catch (e, st) {
        onError?.call(e, st);
        if (!ignoreError) {
          rethrow;
        }
      }
    }
  }
}
