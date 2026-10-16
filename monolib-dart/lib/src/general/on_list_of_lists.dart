/// Provides utilities for processing and formatting two-dimensional grid structures ([List] of [List]s).
///
/// This library includes extensions to generate formatted, plain-text tabular
/// representations directly from in-memory collections, suitable for CLI outputs,
/// logging, and text-based reports.
library;

import 'dart:math';

import 'package:monolib_dart/src/general/on_list.dart';
import 'package:monolib_dart/src/general/table_cell_align_right.dart';

/// An extension that provides architectural capabilities for transforming two-dimensional
/// collections (`List<List>`) into formatted plain-text tables.
///
/// This extension simplifies the generation of human-readable grids directly from in-memory
/// data structures. It handles the structural semantics of tabular layout, including
/// dynamic column width computation, string conversions, and alignment strategies, allowing
/// domain objects or raw rows to be easily visualized in CLI outputs or log files without
/// requiring external templating engines.
extension OnListOfLists on List<List> {
  /// Writes the contents of this two-dimensional list as a formatted, space-separated
  /// text table to the provided [sink].
  ///
  /// This method iterates over the internal grid to compute the maximum width required
  /// for each column based on the string representations of the cells. It then writes
  /// the formatted rows to the [sink] (such as a [StringBuffer] or `IOSink`), which
  /// avoids allocating large contiguous strings in memory, optimizing for large datasets.
  ///
  /// **Alignment Semantics:**
  /// * By default, cell values are converted to strings and left-aligned.
  /// * Values of type [num] or [TableCellAlignRight] are explicitly right-aligned
  ///   within their column.
  /// * `null` values are gracefully converted to empty strings.
  ///
  /// ```dart
  /// final grid = [
  ///   ['Name', 'Age', 'Score'],
  ///   ['Alice', 25, TableCellAlignRight('95.5')],
  ///   ['Bob', 30, 80]
  /// ];
  ///
  /// final buffer = StringBuffer();
  /// grid.formatTable(buffer);
  /// print(buffer.toString());
  /// ```
  ///
  /// [sink] is the destination stream or buffer where the formatted table string chunks
  /// will be written.
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
