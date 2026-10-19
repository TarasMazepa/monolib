import 'dart:async';

/// Extension on [Stream] that filters and casts events by runtime type in a
/// single pass.
extension StreamWhereTypeExtension<T> on Stream<T> {
  /// Filters this stream to emit only elements that are instances of [R],
  /// typed as a `Stream<R>`.
  ///
  /// Non-matching elements are omitted from the returned stream.
  ///
  /// Returns a new [Stream] emitting only the elements of type [R].
  ///
  /// Example:
  /// ```dart
  /// final mixedStream = Stream<Object>.fromIterable([1, 'two', 3.0, 4, 'five']);
  /// final intStream = mixedStream.whereType<int>();
  ///
  /// await for (final number in intStream) {
  ///   print(number); // Outputs: 1, 4
  /// }
  /// ```
  Stream<R> whereType<R>() {
    return transform(
      StreamTransformer<T, R>.fromHandlers(
        handleData: (event, sink) {
          if (event is R) {
            sink.add(event); // Implicitly casts to R
          }
        },
      ),
    );
  }
}
