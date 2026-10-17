/// A converter that formats Dart objects into RFC 4180 compliant CSV strings.
library;

import 'dart:convert';

import 'package:monolib_dart/src/csv/csv_cell_writer.dart';

/// A [Converter] that formats a sequence of Dart objects into a single RFC 4180
/// compliant CSV (Comma-Separated Values) string.
///
/// Architecturally, this class powers the encoding phase of [CsvCodec]. It
/// processes a top-level list of rows, converting each row into comma-separated
/// cells terminated by a `\r\n` sequence.
///
/// To support seamless interoperability with domain objects, [CsvEncoder] employs
/// dynamic dispatch: if a row element within the provided [List] is not already
/// a [List] itself, the encoder dynamically invokes a `toCsv()` method on it.
/// This allows domain models to directly serialize themselves to CSV without
/// intermediate mapping steps.
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
/// final encoder = const CsvEncoder();
/// final csvData = encoder.convert([
///   ['id', 'name'],
///   User(1, 'Alice'),
///   User(2, 'Bob, Jr.'),
/// ]);
///
/// print(csvData);
/// // id,name\r\n1,Alice\r\n2,"Bob, Jr."\r\n
/// ```
class CsvEncoder extends Converter<List<dynamic>, String> {
  /// Constructs a [CsvEncoder] instance.
  const CsvEncoder();

  /// Converts the provided [items] into a standard RFC 4180 CSV [String].
  ///
  /// The [items] parameter expects a sequence of rows. Each element in [items]
  /// is evaluated:
  /// * If it is already a [List], it is treated as a row of cells.
  /// * If it is not a [List], this method dynamically invokes `toCsv()` on the
  ///   object. If `toCsv()` does not return a [List], an [Exception] is thrown.
  ///
  /// Each cell within the resolved row is then converted to a [String] (via
  /// string interpolation if necessary) and safely escaped using
  /// [writeCsvCell] before appending to the final output buffer.
  ///
  /// Returns a complete, fully-formatted CSV string where rows are joined by `\r\n`.
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
