import 'dart:convert';

import 'package:monolib_dart/src/csv/csv_cell_writer.dart';

/// A synchronous [Converter] that encodes a list of rows into an RFC 4180
/// Comma-Separated Values (CSV) [String].
///
/// [CsvEncoder] serves as the synchronous encoder for `CsvCodec.encoder`. It
/// formats a list of rows into comma-separated cells terminated by `\r\n`.
/// Each row element in the input [List] must be either a [List] of cell values
/// or an object implementing a `toCsv()` method that returns a [List].
///
/// Because it buffers the entire output string in memory, use `csvEncodeAsync`
/// instead when streaming large datasets.
///
/// Example:
/// ```dart
/// class User {
///   final int id;
///   final String name;
///   User(this.id, this.name);
///
///   List<dynamic> toCsv() => [id, name];
/// }
///
/// const encoder = CsvEncoder();
/// final csvData = encoder.convert([
///   ['id', 'name'],
///   User(1, 'Alice'),
///   User(2, 'Bob, Jr.'),
/// ]);
/// // Result: 'id,name\r\n1,Alice\r\n2,"Bob, Jr."\r\n'
/// ```
class CsvEncoder extends Converter<List<dynamic>, String> {
  /// Creates a [CsvEncoder].
  const CsvEncoder();

  /// Synchronously encodes [items] into an RFC 4180 CSV [String].
  ///
  /// Each element in [items] is evaluated as a row:
  /// - If it is already a [List], its elements are written as cells.
  /// - Otherwise, `toCsv()` is dynamically invoked on the element. Throws an
  ///   [Exception] if `toCsv()` does not return a [List].
  ///
  /// Each cell is converted to a [String], escaped with [writeCsvCell], and
  /// separated by commas, with each row terminated by `\r\n`.
  @override
  String convert(List<dynamic> items) {
    final result = StringBuffer();
    for (final dynamic item_ in items) {
      dynamic item = item_;
      if (item is! List) {
        item = item.toCsv();
        if (item is! List) {
          throw Exception(
            'Expecting $item to be a List or have toCsv() function that returns List',
          );
        }
      }
      for (int i = 0; i < item.length; i++) {
        dynamic cell = item[i];
        if (cell is! String) {
          cell = '$cell';
        }
        writeCsvCell(cell, result);
        if (i == item.length - 1) {
          result.write('\r\n');
        } else {
          result.write(',');
        }
      }
    }
    return result.toString();
  }
}
