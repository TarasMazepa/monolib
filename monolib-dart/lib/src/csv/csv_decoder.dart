import 'dart:convert';

import 'package:monolib_dart/src/common/list_accumulator_sink.dart';
import 'package:monolib_dart/src/csv/csv_chunked_decoder.dart';

/// A synchronous [Converter] that decodes an RFC 4180 CSV [String] into a
/// list of rows, where each row is a `List<String>` of cells.
///
/// [CsvDecoder] serves as the synchronous decoder for `CsvCodec.decoder`. It
/// delegates parsing to [CsvChunkedDecoder] and collects all emitted rows in
/// memory using a [ListAccumulatorSink].
///
/// Because it buffers the entire result set in memory before returning, use
/// the stream-based [CsvChunkedDecoder] instead when processing large files or
/// streams.
///
/// Example:
/// ```dart
/// const decoder = CsvDecoder();
/// final rows = decoder.convert('id,name\n1,"Alice"');
/// print(rows); // [['id', 'name'], ['1', 'Alice']]
/// ```
class CsvDecoder extends Converter<String, List<List<String>>> {
  /// Creates a [CsvDecoder].
  const CsvDecoder();

  /// Synchronously decodes the CSV string [items] into a list of parsed rows.
  ///
  /// Feeds [items] through [CsvChunkedDecoder.startChunkedConversion] and
  /// accumulates the emitted rows in a [ListAccumulatorSink]. Returns an empty
  /// list if [items] is empty.
  @override
  List<List<String>> convert(String items) {
    final sink = ListAccumulatorSink<List<String>>();
    const CsvChunkedDecoder().startChunkedConversion(sink)
      ..add(items)
      ..close();
    return sink.results;
  }
}
