import 'dart:async';

/// Extension on [EventSink] that provides [tryAddError] for safely adding
/// errors without throwing a [StateError] when the sink is closed.
extension OnEventSink<T> on EventSink<T> {
  /// Adds [error] (and optional [stackTrace]) to this sink if it is still open,
  /// ignoring any [StateError] caused by a closed sink.
  ///
  /// For a [StreamController], this checks [StreamController.isClosed] before
  /// calling [StreamController.addError]. For other [EventSink]
  /// implementations, it calls [EventSink.addError] inside a `try`/`catch`
  /// block and ignores any [StateError].
  ///
  /// If [ignoreError] is `true`, any other exception thrown while adding
  /// [error] is also caught and suppressed; otherwise, non-[StateError]
  /// exceptions are rethrown.
  ///
  /// If [onError] is provided, it is invoked with any non-[StateError]
  /// exception and stack trace caught while adding [error].
  ///
  /// Example:
  /// ```dart
  /// final controller = StreamController<String>();
  ///
  /// controller.tryAddError(
  ///   FormatException('Invalid input data'),
  ///   ignoreError: true,
  ///   onError: (err, st) => print('Failed to add error: $err'),
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
