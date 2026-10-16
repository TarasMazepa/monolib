import 'dart:convert';

import 'package:monolib_dart/src/csv/csv_decoder.dart';
import 'package:monolib_dart/src/csv/csv_encoder.dart';

/// A [Codec] that encodes and decodes Comma-Separated Values (CSV) format.
///
/// This codec provides a bidirectional conversion between a sequence of Dart
/// objects (usually [List]s representing rows) and a CSV-formatted [String].
///
/// When encoding, it converts a [List] of elements (which are typically lists of
/// values, or objects with a `toCsv()` method that return a list) into a single
/// RFC 4180 compliant CSV string using [CsvEncoder].
///
/// When decoding, it parses a CSV string into a list of rows, where each row
/// is a [List] of [String] cells using [CsvDecoder].
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
/// print(csvString);
/// // id,name\r\n1,Alice\r\n2,"Bob, Jr."\r\n
///
/// // Decoding
/// final rows = codec.decode('id,name\r\n1,Alice\r\n2,"Bob, Jr."\r\n');
/// print(rows);
/// // [['id', 'name'], ['1', 'Alice'], ['2', 'Bob, Jr.']]
/// ```
class CsvCodec extends Codec<List<dynamic>, String> {
  /// Creates a new instance of [CsvCodec] for CSV encoding and decoding.
  const CsvCodec();

  /// Returns a [CsvEncoder] to convert a list of rows into a CSV string.
  ///
  /// The input should be a [List] of rows, where each row is either a [List]
  /// of cell values, or an object implementing `toCsv()` that returns a [List].
  @override
  Converter<List<dynamic>, String> get encoder => const CsvEncoder();

  /// Returns a [CsvDecoder] to parse a CSV string into a list of rows.
  ///
  /// The resulting list contains a [List] of [String] cells for each row found
  /// in the input CSV string.
  @override
  Converter<String, List<List<String>>> get decoder => const CsvDecoder();
}
