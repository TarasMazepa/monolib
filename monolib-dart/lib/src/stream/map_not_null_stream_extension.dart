import 'dart:async';

/// An architectural extension on [Stream] that optimizes stream processing pipelines
/// by seamlessly combining type mapping and null-filtering into a single operation.
///
/// Within the repository architecture, [MapNotNullStreamExtension] is critical for
/// processing high-throughput streams (such as incoming JSON Lines from `JsonlMappedDecoder`
/// or CSV records from `CsvMappedDecoder`) where invalid or ignored elements need to be
/// safely dropped without allocating intermediate wrappers or triggering downstream null-safety errors.
/// It bypasses the overhead of distinct `map` followed by `where` steps.
extension MapNotNullStreamExtension<T> on Stream<T> {
  /// Transforms each event in the stream by applying the provided [mapper] function,
  /// and silently drops any results that evaluate to null.
  ///
  /// This method enables safe, down-stream narrowing of data types. It consumes a `Stream<T>`
  /// and yields a strictly non-null `Stream<R>`. If [mapper] returns `null`, the event is
  /// simply ignored and not forwarded to the returned stream, effectively acting as both a
  /// map and filter simultaneously.
  ///
  /// The [mapper] parameter is a synchronous function evaluated for every incoming event
  /// of type `T`, and must return a nullable result `R?`.
  ///
  /// Example:
  /// ```dart
  /// final rawStream = Stream.fromIterable(['123', 'invalid', '456']);
  /// // Safe parsing: ignores 'invalid' safely.
  /// final parsedStream = rawStream.mapNotNull((s) => int.tryParse(s));
  /// // Output stream emits: [123, 456]
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
