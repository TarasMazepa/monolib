import 'dart:async';

extension FutureEventSinkExtension<T> on Future<EventSink<T>> {
  EventSink<T> unwrap() {
    final controller = StreamController<T>(sync: true);

    then(
      (resolvedSink) {
        controller.stream.listen(
          resolvedSink.add,
          onError: resolvedSink.addError,
          onDone: resolvedSink.close,
        );
      },
    ).catchError(
      (Object error, StackTrace stackTrace) {
        controller.close();
        Zone.current.handleUncaughtError(error, stackTrace);
      },
    );

    return controller.sink;
  }
}
