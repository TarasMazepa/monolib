import 'dart:async';

extension OnStreamController<T> on StreamController<T> {
  void tryAdd(T event) {
    if (!isClosed) {
      add(event);
    }
  }
}
