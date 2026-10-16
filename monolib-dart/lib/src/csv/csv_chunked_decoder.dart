/// Provides a chunk-based decoder for converting raw CSV strings into lists of rows.
library;

import 'package:monolib_dart/src/common/chunked_only_converter.dart';
import 'package:monolib_dart/src/csv/csv_base_chunk_sink.dart';

/// A streaming converter that parses chunked CSV string data into lists of string columns.
///
/// [CsvChunkedDecoder] acts as the architectural foundation for CSV ingestion.
/// It strictly operates as a [ChunkedOnlyConverter] to prevent unintended synchronous
/// string evaluations. Instead of duplicating RFC 4180 parsing logic, it delegates
/// the stateful parsing mechanics to [CsvBaseChunkSink].
///
/// This decoder is used natively to transform asynchronous string streams, and it also
/// powers synchronous adapters like [CsvDecoder], which buffer the output of this chunked
/// conversion into a complete list of rows.
///
/// Example:
/// ```dart
/// final sink = ListAccumulatorSink<List<String>>();
/// const CsvChunkedDecoder().startChunkedConversion(sink)
///   ..add('name,age\n')
///   ..add('Alice,30\n')
///   ..close();
/// print(sink.results); // [['name', 'age'], ['Alice', '30']]
/// ```
class CsvChunkedDecoder extends ChunkedOnlyConverter<String, List<String>> {
  /// Creates a new [CsvChunkedDecoder] instance.
  const CsvChunkedDecoder();

  /// Starts a chunked conversion by bridging the input CSV chunks to the output [sink].
  ///
  /// This returns a [_CsvChunkedDecoderSink] which consumes `String` inputs, applies
  /// stateful CSV parsing via [CsvBaseChunkSink], and emits completed `List<String>`
  /// rows to the provided [sink].
  @override
  Sink<String> startChunkedConversion(Sink<List<String>> sink) {
    return _CsvChunkedDecoderSink(sink);
  }
}

/// An internal [Sink] adapter that feeds parsed CSV rows into the target output sink.
///
/// Inheriting from [CsvBaseChunkSink], this class holds the actual state machine for
/// handling CSV chunks, including escaping and quoting. When [CsvBaseChunkSink] successfully
/// parses a complete row, it calls [handleRow], which simply forwards the extracted row
/// directly to the [outSink].
class _CsvChunkedDecoderSink extends CsvBaseChunkSink<List<String>> {
  /// Creates a sink adapter that forwards parsed `List<String>` rows to the underlying sink.
  _CsvChunkedDecoderSink(super.outSink);

  /// Receives a fully parsed [row] from the underlying [CsvBaseChunkSink] logic and adds it
  /// to the output stream.
  @override
  void handleRow(List<String> row) {
    outSink.add(row);
  }
}
