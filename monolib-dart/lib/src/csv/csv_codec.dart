import 'dart:convert';

import 'package:monolib_dart/src/csv/csv_decoder.dart';
import 'package:monolib_dart/src/csv/csv_encoder.dart';

/// A [Codec] that encodes and decodes RFC 4180 Comma-Separated Values (CSV) strings.
///
/// [CsvCodec] provides bidirectional conversion between a list of rows and an
/// RFC 4180 CSV-formatted [String] by delegating to [CsvEncoder] and
/// [CsvDecoder].
///
/// When encoding, it converts a [List] of rows (where each row is either a
/// [List] of cell values or an object implementing `toCsv()`) into a
/// `\r\n`-delimited CSV [String]. When decoding, it parses a CSV [String] into
/// a `List<List<String>>` of rows and cells.
///
/// Example:
/// ```dart
/// const codec = CsvCodec();
///
/// // Encoding
/// final csvString = codec.encode([
///   ['id', 'name'],
///   [1, 'Alice'],
///   [2, 'Bob, Jr.'],
/// ]);
/// // Result: 'id,name\r\n1,Alice\r\n2,"Bob, Jr."\r\n'
///
/// // Decoding
/// final rows = codec.decode(csvString);
/// // Result: [['id', 'name'], ['1', 'Alice'], ['2', 'Bob, Jr.']]
/// ```
class CsvCodec extends Codec<List<dynamic>, String> {
  /// Creates a [CsvCodec] for encoding and decoding CSV strings.
  const CsvCodec();

  /// Returns a [CsvEncoder] that converts a list of rows into a CSV [String].
  ///
  /// Each element in the input list must be either a [List] of cell values or
  /// an object with a `toCsv()` method that returns a [List].
  @override
  Converter<List<dynamic>, String> get encoder => const CsvEncoder();

  /// Returns a [CsvDecoder] that parses a CSV [String] into a list of rows.
  ///
  /// Each row in the returned list is a `List<String>` containing the parsed
  /// cells for that row.
  @override
  Converter<String, List<List<String>>> get decoder => const CsvDecoder();
}
