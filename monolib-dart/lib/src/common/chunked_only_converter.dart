import 'dart:convert';

/// A base [Converter] for stream transformers that only support chunked
/// conversion.
///
/// Subclasses implement [startChunkedConversion] to process streaming data
/// incrementally, while calling [convert] synchronously always throws an
/// [UnsupportedError].
///
/// Example:
/// ```dart
/// class MyLogDecoder extends ChunkedOnlyConverter<String, LogEntry> {
///   @override
///   Sink<String> startChunkedConversion(Sink<LogEntry> sink) {
///     return _MyLogChunkSink(sink);
///   }
/// }
/// ```
abstract class ChunkedOnlyConverter<S, T> extends Converter<S, T> {
  /// Creates a [ChunkedOnlyConverter].
  const ChunkedOnlyConverter();

  /// Always throws an [UnsupportedError] because this converter only supports
  /// chunked conversion via [startChunkedConversion] or `Stream.transform`.
  @override
  T convert(S input) {
    throw UnsupportedError('This converter only supports chunked conversion');
  }
}
