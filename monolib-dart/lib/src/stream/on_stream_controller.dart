import 'dart:async';

extension OnStreamController<T> on StreamController<T> {
  void tryAdd(T event, {bool ignoreError = false}) {
    if (!isClosed) {
      if (ignoreError) {
        try {
          add(event);
        } catch (_) {}
      } else {
        add(event);
      }
    }
  }

  void tryAddError(
    Object error, {
    StackTrace? stackTrace,
    bool ignoreError = false,
  }) {
    if (!isClosed) {
      if (ignoreError) {
        try {
          addError(error, stackTrace);
        } catch (_) {}
      } else {
        addError(error, stackTrace);
      }
    }
  }
}
