import 'dart:async';

extension OnIterableOfStreamControllers<T> on Iterable<StreamController<T>> {
  void onEachAdd(T event) {
    for (final listener in this) {
      try {
        listener.add(event);
      } catch (_) {
        // ignore
      }
    }
  }

  void onEachAddError(Object error, [StackTrace? stackTrace]) {
    for (final listener in this) {
      try {
        listener.addError(error, stackTrace);
      } catch (_) {
        // ignore
      }
    }
  }
}
