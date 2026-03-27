import 'dart:async';

import '../general/on_list.dart';

extension type const StreamWithClose<T>._(
    ({
      Stream<T> stream,
      List<StreamSubscription> subscriptions,
      StreamController<T> controller,
    }) _data) {
  StreamWithClose({
    required Stream<T> stream,
    required List<StreamSubscription> subscriptions,
    required StreamController<T> controller,
  }) : this._((
          stream: stream,
          subscriptions: subscriptions,
          controller: controller,
        ));

  Stream<T> get stream => _data.stream;

  Future<void> close() {
    return _data.subscriptions.drainMap((s) => s.cancel()).followedBy([
      _data.controller.close(),
    ]).wait;
  }
}
