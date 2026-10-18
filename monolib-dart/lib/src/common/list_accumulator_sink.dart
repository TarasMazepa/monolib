/// An in-memory [Sink] that accumulates added events into a [List].
///
/// Synchronous decoders (such as `JsonlDecoder` and `CsvDecoder`) pass a
/// [ListAccumulatorSink] to their chunked counterparts (`JsonlChunkedDecoder`
/// and `CsvChunkedDecoder`) to collect all decoded records into [results].
///
/// Example:
/// ```dart
/// List<dynamic> convert(String items) {
///   final sink = ListAccumulatorSink<dynamic>();
///   JsonlChunkedDecoder(jsonCodec: jsonCodec).startChunkedConversion(sink)
///     ..add(items)
///     ..close();
///   return sink.results;
/// }
/// ```
class ListAccumulatorSink<T> implements Sink<T> {
  /// The list of elements accumulated via [add].
  final List<T> results = [];

  /// Appends [data] to [results].
  @override
  void add(T data) {
    results.add(data);
  }

  /// Closes this sink (a no-op for in-memory list accumulation).
  @override
  void close() {}
}
