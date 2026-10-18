import 'package:monolib_dart/src/common/chunked_only_converter.dart';
import 'package:monolib_dart/src/csv/csv_base_chunk_sink.dart';

/// A streaming converter that parses chunked RFC 4180 CSV string data into
/// rows of string cells (`List<String>`).
///
/// [CsvChunkedDecoder] extends [ChunkedOnlyConverter] and delegates stateful
/// CSV row and field parsing to [CsvBaseChunkSink]. It transforms asynchronous
/// `Stream<String>` pipelines directly into streams of `List<String>` rows and
/// also underpins synchronous converters such as `CsvDecoder`.
///
/// Example:
/// ```dart
/// final rowStream = File('data.csv')
///     .openRead()
///     .transform(utf8.decoder)
///     .transform(const CsvChunkedDecoder());
///
/// await for (final row in rowStream) {
///   print(row);
/// }
/// ```
class CsvChunkedDecoder extends ChunkedOnlyConverter<String, List<String>> {
  /// Creates a [CsvChunkedDecoder].
  const CsvChunkedDecoder();

  /// Starts a chunked conversion that parses incoming CSV string chunks and
  /// emits `List<String>` rows to [sink].
  @override
  Sink<String> startChunkedConversion(Sink<List<String>> sink) {
    return _CsvChunkedDecoderSink(sink);
  }
}

/// Internal [CsvBaseChunkSink] implementation for [CsvChunkedDecoder].
class _CsvChunkedDecoderSink extends CsvBaseChunkSink<List<String>> {
  /// Creates a sink that forwards parsed `List<String>` rows to [outSink].
  _CsvChunkedDecoderSink(super.outSink);

  /// Emits the parsed [row] directly to [outSink].
  @override
  void handleRow(List<String> row) {
    outSink.add(row);
  }
}
