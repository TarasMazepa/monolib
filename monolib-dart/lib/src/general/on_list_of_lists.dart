import 'dart:math';

import 'package:monolib_dart/src/general/on_list.dart';
import 'package:monolib_dart/src/general/table_cell_align_right.dart';

/// Extension on [List] of [List]s that formats two-dimensional data as a
/// plain-text table.
extension OnListOfLists on List<List> {
  /// Writes this two-dimensional list as a space-padded plain-text table to
  /// [sink].
  ///
  /// Computes the maximum string width of each column and pads every cell to
  /// match its column width:
  /// - Values of type [num] or [TableCellAlignRight] are right-aligned.
  /// - All other values (including `TableCellAlignLeft`) are left-aligned.
  /// - `null` values are rendered as empty strings.
  ///
  /// Example:
  /// ```dart
  /// final grid = [
  ///   ['Name', 'Age', 'Score'],
  ///   ['Alice', 25, TableCellAlignRight('95.5')],
  ///   ['Bob', 30, 80],
  /// ];
  ///
  /// final buffer = StringBuffer();
  /// grid.formatTable(buffer);
  /// print(buffer.toString());
  /// ```
  void formatTable(StringSink sink) {
    final maxWidths = List.filled(
      fold(0, (maxSize, item) => max(maxSize, item.length)),
      0,
    );
    final strings = toMappedList(
      (list) => list.toMappedList(
        (x) => switch (x) {
          null => '',
          _ => x.toString(),
        },
        growable: false,
      ),
      growable: false,
    );
    for (final list in strings) {
      for (int i = 0; i < list.length; i++) {
        maxWidths[i] = max(maxWidths[i], list[i].length);
      }
    }
    for (int l = 0; l < strings.length; l++) {
      final list = strings[l];
      for (int i = 0; i < list.length; i++) {
        final cell = this[l][i];
        if (cell is num || cell is TableCellAlignRight) {
          sink.write(list[i].padLeft(maxWidths[i]));
        } else {
          sink.write(list[i].padRight(maxWidths[i]));
        }
        if (i < list.length - 1 && maxWidths[i] > 0) {
          sink.write(' ');
        }
      }
      sink.write('\n');
    }
  }
}
