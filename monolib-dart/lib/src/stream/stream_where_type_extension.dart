import 'dart:async';

extension StreamWhereTypeExtension<T> on Stream<T> {
  /// Filters elements by type [R] using a single stream wrapper.
  Stream<R> whereType<R>() {
    return transform(StreamTransformer<T, R>.fromHandlers(
      handleData: (event, sink) {
        if (event is R) {
          sink.add(event); // Implicitly casts to R
        }
      },
    ));
  }
}
