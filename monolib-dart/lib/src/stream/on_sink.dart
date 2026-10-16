/// A utility library that enhances [Sink] instances with safe event emission
/// capabilities, ensuring robust event handling in reactive architectures.
library;

import 'dart:async';

/// Provides robust, fail-safe event emission capabilities for any [Sink].
///
/// In standard Dart streams, adding an event to an already closed [Sink] (such as
/// a [StreamController] or an `IOSink`) throws an unhandled [StateError]. This extension
/// mitigates that by introducing a resilient way to broadcast events across asynchronous
/// stream pipelines or multi-sink architectures where the exact lifecycle state of the
/// sink might not be easily determined at the moment of event emission.
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
