/// A utility library that enhances [Sink] instances with safe event emission
/// capabilities, ensuring robust event handling in reactive architectures.
library;

import 'dart:async';

/// A resilient boundary proxy that shields upstream event producers from asynchronous
/// sink teardown failures.
///
/// In complex, highly concurrent systems, an upstream event producer often lacks
/// perfectly synchronized knowledge of a downstream [Sink]'s exact lifecycle state.
/// For example, if a background task attempts to push data to an `IOSink` or
/// [StreamController] that a different subsystem concurrently closed due to user
/// cancellation or network timeout, standard Dart streams will throw an aggressive,
/// unhandled [StateError] that crashes the entire isolate.
///
/// This extension resolves this by establishing a defensive emission boundary.
/// It introduces a "try-add" paradigm, absorbing expected lifecycle exceptions
/// (like adding to a closed sink) to maintain pipeline stability without
/// requiring defensive `isClosed` checks everywhere in the codebase.
extension OnSink<T> on Sink<T> {
  /// Attempts to safely broadcast an [event] to this sink without throwing
  /// a [StateError] if the sink has already been closed.
  ///
  /// This method provides specialized, performant fast-paths for [StreamController]
  /// instances by evaluating their [StreamController.isClosed] property directly.
  /// For other [Sink] implementations that do not expose such state, it
  /// attempts to add the event and gracefully catches and ignores any resulting
  /// [StateError].
  ///
  /// The [event] parameter represents the primary payload to be dispatched to
  /// downstream listeners or underlying resources.
  ///
  /// If [ignoreError] is `true`, any non-[StateError] exceptions encountered
  /// during the internal process of adding the [event] to the sink will be silently
  /// caught, preventing unexpected crashes during cleanup or teardown phases. If `false`
  /// (the default), such exceptions are rethrown.
  ///
  /// The [onError] callback provides a mechanism to monitor or log any internal
  /// exceptions (along with their [StackTrace]) that arise specifically from the act
  /// of dispatching the original [event] into the sink. This is especially useful when
  /// [ignoreError] is `true`, allowing these swallowed exceptions to still be tracked
  /// and recorded without crashing the active zone.
  ///
  /// ```dart
  /// final sink = StreamController<List<int>>();
  ///
  /// // Safely emit a chunk of data. This avoids crashes even if the sink
  /// // was concurrently closed in a different part of the system.
  /// sink.tryAdd(
  ///   [1, 2, 3],
  ///   ignoreError: true,
  ///   onError: (internalErr, st) => print('Failed to broadcast event: $internalErr'),
  /// );
  /// ```
  void tryAdd(
    T event, {
    bool ignoreError = false,
    void Function(Object error, StackTrace stackTrace)? onError,
  }) {
    final self = this;
    if (self is StreamController<T>) {
      if (!self.isClosed) {
        if (ignoreError) {
          try {
            self.add(event);
          } catch (e, st) {
            onError?.call(e, st);
          }
        } else {
          self.add(event);
        }
      }
    } else {
      try {
        add(event);
      } on StateError {
        // Ignore because Sink has no isClosed property and throws StateError when closed.
      } catch (e, st) {
        onError?.call(e, st);
        if (!ignoreError) {
          rethrow;
        }
      }
    }
  }
}
