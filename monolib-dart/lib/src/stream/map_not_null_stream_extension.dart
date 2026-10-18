import 'dart:async';

/// Extension on [Stream] that combines mapping and null-filtering into a
/// single transformation.
extension MapNotNullStreamExtension<T> on Stream<T> {
  /// Transforms each event in this stream by applying [mapper] and emitting
  /// only non-null results.
  ///
  /// If [mapper] returns `null` for an incoming event, that event is omitted
  /// from the returned `Stream<R>`.
  ///
  /// Example:
  /// ```dart
  /// final rawStream = Stream.fromIterable(['123', 'invalid', '456']);
  /// final parsedStream = rawStream.mapNotNull((s) => int.tryParse(s));
  /// // Emits: 123, 456
  /// ```
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
