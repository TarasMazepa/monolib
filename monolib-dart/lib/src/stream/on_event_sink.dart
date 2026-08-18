import 'dart:async';

extension OnEventSink<T> on EventSink<T> {
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
