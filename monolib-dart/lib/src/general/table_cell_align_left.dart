/// A wrapper class for overriding alignment behavior in tabular string generation.
library;

/// A structural wrapper that forces a table cell to be left-aligned when rendered.
///
/// In the tabular string generation architecture provided by [OnListOfLists.formatTable],
/// `num` values (integers, doubles) are automatically right-aligned by default.
/// Wrapping a numerical value or any other object in [TableCellAlignLeft] overrides
/// this behavior, instructing the formatter to pad the generated string on the right,
/// resulting in left-aligned output within the calculated column width.
///
/// ```dart
/// final table = [
///   ['ID', 'Value'],
///   [1, 100], // 100 will be right-aligned
///   [2, TableCellAlignLeft(200)], // 200 will be left-aligned
/// ];
/// final sink = StringBuffer();
/// table.formatTable(sink);
/// ```
class TableCellAlignLeft {
  /// The underlying value to be formatted and rendered in the table cell.
  ///
  /// This [value] can be of any type, though typically it wraps a `num`
  /// to override its default right-alignment. It will be converted to a
  /// string representation by [OnListOfLists.formatTable] during formatting.
  final dynamic value;

  /// Creates a [TableCellAlignLeft] to force left-alignment of the provided [value].
  TableCellAlignLeft(this.value);

  /// Returns the string representation of the underlying [value].
  ///
  /// This ensures that the cell's textual content remains identical to
  /// what it would have been if the [value] had not been wrapped, while
  /// transparently applying the structural alignment override.
  @override
  String toString() {
    return '$value';
  }
}
