/// A cell wrapper that forces right alignment when formatted by `formatTable`.
///
/// By default, `formatTable` right-aligns [num] values and left-aligns all
/// other values. Wrapping a non-numeric value in [TableCellAlignRight]
/// overrides this behavior so the cell is padded on the left.
///
/// Example:
/// ```dart
/// final table = [
///   ['Name', 'Score'],
///   ['Alice', TableCellAlignRight('95.5%')],
///   ['Bob', TableCellAlignRight('80.0%')],
/// ];
/// final buffer = StringBuffer();
/// table.formatTable(buffer);
/// ```
class TableCellAlignRight {
  /// The underlying cell value to format as a right-aligned string.
  final dynamic value;

  /// Creates a [TableCellAlignRight] wrapper around [value].
  TableCellAlignRight(this.value);

  /// Returns the string representation of [value].
  @override
  String toString() {
    return '$value';
  }
}
