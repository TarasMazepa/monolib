import 'dart:async';

extension OnSink<T> on Sink<T> {
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
