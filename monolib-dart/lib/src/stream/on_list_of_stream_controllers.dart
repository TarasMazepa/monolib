import 'dart:async';

extension OnListOfStreamControllers<T> on List<StreamController<T>> {
  void addAndSetupOnCancel(
    StreamController<T> listener, {
    void Function()? onEmpty,
  }) {
    listener.onCancel = () {
      try {
        remove(listener);
      } catch (_) {
        // ignore
      }
      if (isEmpty) {
        try {
          onEmpty?.call();
        } catch (_) {
          // ignore
        }
      }
    };
    add(listener);
  }
}
