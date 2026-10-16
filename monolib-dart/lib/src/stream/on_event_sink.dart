/// A utility library that enhances [EventSink] instances with safe error emission
/// capabilities, ensuring robust error handling in reactive architectures.
library;

import 'dart:async';

/// Provides robust, fail-safe error emission capabilities for any [EventSink].
///
/// In standard Dart streams, adding an error to an already closed [EventSink] (such as
/// a [StreamController]) throws an unhandled [StateError]. This extension mitigates that
/// by introducing a resilient way to broadcast errors across asynchronous stream pipelines
/// or multi-sink architectures where the exact lifecycle state of the sink might not be
/// easily determined at the moment of error emission.
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
