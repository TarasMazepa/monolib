import 'dart:async';

extension OnEventSink<T> on EventSink<T> {
  void tryAddError(
    Object error, {
    StackTrace? stackTrace,
    bool ignoreError = false,
  }) {
    final self = this;
    if (self is StreamController<T>) {
      if (!self.isClosed) {
        if (ignoreError) {
          try {
            self.addError(error, stackTrace);
          } catch (_) {}
        } else {
          self.addError(error, stackTrace);
        }
      }
    } else {
      try {
        addError(error, stackTrace);
      } on StateError {
        // Ignore StateError, which typically means the sink is closed
      } catch (_) {
        if (!ignoreError) {
          rethrow;
        }
      }
    }
  }
}
