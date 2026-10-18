import 'dart:async';

/// Extension on [Sink] that provides [tryAdd] for safely adding events without
/// throwing a [StateError] when the sink is closed.
extension OnSink<T> on Sink<T> {
  /// Adds [event] to this sink if it is still open, ignoring any [StateError]
  /// caused by a closed sink.
  ///
  /// For a [StreamController], this checks [StreamController.isClosed] before
  /// calling [StreamController.add]. For other [Sink] implementations, it calls
  /// [Sink.add] inside a `try`/`catch` block and ignores any [StateError].
  ///
  /// If [ignoreError] is `true`, any other exception thrown while adding
  /// [event] is also caught and suppressed; otherwise, non-[StateError]
  /// exceptions are rethrown.
  ///
  /// If [onError] is provided, it is invoked with any non-[StateError]
  /// exception and stack trace caught while adding [event].
  ///
  /// Example:
  /// ```dart
  /// final sink = StreamController<List<int>>();
  ///
  /// sink.tryAdd(
  ///   [1, 2, 3],
  ///   ignoreError: true,
  ///   onError: (err, st) => print('Failed to add event: $err'),
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
