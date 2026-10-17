/// Provides [ListAccumulatorSink], an in-memory buffering proxy for bridging synchronous and chunked conversions.
library;

/// A synchronous, in-memory buffering proxy that accumulates events into a single [List].
///
/// Architecturally, [ListAccumulatorSink] bridges stream-based (chunked) processing
/// and standard synchronous conversions. By injecting this sink into chunked decoders
/// (such as `JsonlChunkedDecoder` or `CsvChunkedDecoder`), synchronous decoders
/// (like `JsonlDecoder` and `CsvDecoder`) can fully delegate their parsing state machine
/// without needing to duplicate complex structural parsing logic.
///
/// It acts as the termination point in these pseudo-streaming pipelines, silently
/// appending emitted objects of type [T] into the [results] list, which can then be
/// accessed directly once the conversion is closed.
///
/// Example:
/// ```dart
/// List<dynamic> convert(String items) {
///   final sink = ListAccumulatorSink<dynamic>();
///   // Delegate stateful decoding to the chunked component,
///   // gathering outputs synchronously into our sink.
///   JsonlChunkedDecoder(jsonCodec: jsonCodec).startChunkedConversion(sink)
///     ..add(items)
///     ..close();
///   return sink.results;
/// }
/// ```
class ListAccumulatorSink<T> implements Sink<T> {
  /// The accumulated output from the pipeline.
  ///
  /// This list dynamically grows as new [data] is passed to [add]. It is typically
  /// returned to the caller only after [close] is invoked on the driving component
  /// to ensure the complete dataset has been materialized.
  final List<T> results = [];

  /// Receives a single decoded element and appends it to [results].
  ///
  /// [data] is the materialized object of type [T] emitted by the upstream
  /// chunked converter (e.g. a parsed JSON object or a CSV row).
  @override
  void add(T data) {
    results.add(data);
  }

  /// Concludes the event stream for this sink.
  ///
  /// Since this sink merely accumulates events in memory without allocating native
  /// resources or managing asynchronous controllers, [close] operates as a no-op.
  @override
  void close() {}
}
