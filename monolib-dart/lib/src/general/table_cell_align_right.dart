/// An architectural wrapper class that overrides the default left-alignment
/// in tabular text outputs.
///
/// Within the data-formatting architecture (specifically [OnListOfLists.formatTable]),
/// table cells are left-aligned by default, while [num] types are automatically
/// right-aligned. [TableCellAlignRight] provides an explicit override mechanism
/// to force right-alignment for arbitrary non-numeric domain objects (e.g.,
/// formatted strings, customized currency representations, or right-to-left text)
/// without altering the underlying table generation logic.
///
/// Example:
/// ```dart
/// final table = [
///   ['Alice', 25, TableCellAlignRight('95.5')],
/// ];
/// table.formatTable(stdout); // The '95.5' cell will be right-aligned
/// ```
class TableCellAlignRight {
  /// The underlying domain value or formatted string to be displayed.
  final dynamic value;

  /// Wraps a [value] to explicitly request right-alignment during table rendering.
  TableCellAlignRight(this.value);

  /// Transparently unwraps the underlying [value], allowing table generators
  /// (like [OnListOfLists.formatTable]) to format the string correctly without
  /// manually introspecting the wrapper.
  @override
  String toString() {
    return '$value';
  }
}
