/// A cell wrapper that forces left alignment when formatted by `formatTable`.
///
/// By default, `formatTable` right-aligns [num] values and left-aligns all
/// other values. Wrapping a value (such as a [num]) in [TableCellAlignLeft]
/// overrides this behavior so the cell is padded on the right.
///
/// Example:
/// ```dart
/// final table = [
///   ['ID', 'Value'],
///   [1, 100],
///   [2, TableCellAlignLeft(200)],
/// ];
/// final buffer = StringBuffer();
/// table.formatTable(buffer);
/// ```
class TableCellAlignLeft {
  /// The underlying cell value to format as a left-aligned string.
  final dynamic value;

  /// Creates a [TableCellAlignLeft] wrapper around [value].
  const TableCellAlignLeft(this.value);

  /// Returns the string representation of [value].
  @override
  String toString() {
    return '$value';
  }
}
