import 'dart:async';

extension MapNotNullStreamExtension<T> on Stream<T> {
  /// Maps events to [R] and filters out null results in a single, efficient pass.
  Stream<R> mapNotNull<R>(R? Function(T event) mapper) {
    return transform(
      StreamTransformer<T, R>.fromHandlers(
        handleData: (event, sink) {
          final result = mapper(event);
          if (result != null) {
            sink.add(result); // Implicitly safely casts to R
          }
        },
      ),
    );
  }
}
