import 'dart:convert';

/// An architectural base class designed exclusively for chunked (stream) conversions.
///
/// This class serves as a foundational layer for stream transformers (such as
/// `CsvMappedDecoder` and `JsonlMappedDecoder`) that are intended to process
/// high-throughput data continuously rather than loading it entirely into memory.
/// By extending [ChunkedOnlyConverter], subclasses explicitly signal their
/// streaming nature and inherit behavior that prevents blocking the event loop
/// with large, synchronous conversions.
///
/// If the synchronous [convert] method is invoked, it intentionally throws an
/// [UnsupportedError] to prevent accidental memory exhaustion or unexpected
/// blocking behavior. Subclasses only need to implement [startChunkedConversion]
/// to provide their specific stream parsing logic (often utilizing a structural
/// chunk sink like `CsvBaseChunkSink` or `JsonlBaseChunkSink`).
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
  /// Initializes the base converter.
  const ChunkedOnlyConverter();

  /// Throws an [UnsupportedError] because this converter is strictly restricted
  /// to asynchronous, chunk-based data ingestion.
  ///
  /// The synchronous [input] parameter is ignored, as this method is explicitly
  /// disabled architecturally to prevent high memory consumption or blocking the
  /// execution thread on large payloads. Consumers must instead use
  /// [startChunkedConversion] or attach this converter to a stream via
  /// `Stream.transform`.
  @override
  T convert(S input) {
    throw UnsupportedError('This converter only supports chunked conversion');
  }
}
