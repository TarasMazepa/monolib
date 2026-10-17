import 'dart:typed_data';

/// A specialized, high-performance dense 2D data structure for 32-bit integers.
///
/// Backed by a [Int32List] for raw C-level performance, memory contiguity,
/// and maximum CPU cache locality. Use this structure when you need a 2D matrix
/// of integers with very fast read/write access.
///
/// Example:
/// ```dart
/// final table = Int32Table.filled(2, 2, 0);
/// table.set(0, 1, 42);
/// print(table.get(0, 1)); // Prints 42
/// ```
class Int32Table {
  final Int32List _data;
  final int _rows;
  final int _columns;

  /// The number of rows in the table.
  ///
  /// Returns the maximum vertical dimension of this table.
  ///
  /// Example:
  /// ```dart
  /// final table = Int32Table.filled(3, 4, 0);
  /// print(table.rows); // Prints 3
  /// ```
  int get rows => _rows;

  /// The number of columns in the table.
  ///
  /// Returns the maximum horizontal dimension of this table.
  ///
  /// Example:
  /// ```dart
  /// final table = Int32Table.filled(3, 4, 0);
  /// print(table.columns); // Prints 4
  /// ```
  int get columns => _columns;

  /// Creates a dense table with the given number of [rows] and [columns],
  /// filled with [fillValue].
  ///
  /// The [rows] and [columns] parameters must be non-negative integers. If they
  /// are 0, an empty table is created. The [fillValue] will populate every cell
  /// in the newly created table.
  ///
  /// Throws an [AssertionError] if either [rows] or [columns] is negative.
  ///
  /// Example:
  /// ```dart
  /// // Creates a 2x3 table filled with the value 7
  /// final table = Int32Table.filled(2, 3, 7);
  /// print(table.get(1, 2)); // Prints 7
  /// ```
  Int32Table.filled(int rows, int columns, int fillValue)
      : assert(rows >= 0, 'rows must be non-negative'),
        assert(columns >= 0, 'columns must be non-negative'),
        _rows = rows,
        _columns = columns,
        _data = Int32List(rows * columns)
          ..fillRange(0, rows * columns, fillValue);

  /// Creates a dense table with the given number of [rows] and [columns],
  /// generating values dynamically using the [generator] function.
  ///
  /// The [generator] is a callback that receives the current `row` and `col`
  /// indices and returns the integer value to store at that position.
  /// The [rows] and [columns] parameters must be non-negative integers.
  ///
  /// Throws an [AssertionError] if either [rows] or [columns] is negative.
  ///
  /// Example:
  /// ```dart
  /// // Creates a 3x3 identity matrix
  /// final table = Int32Table.generate(3, 3, (row, col) => row == col ? 1 : 0);
  /// print(table.get(0, 0)); // Prints 1
  /// print(table.get(0, 1)); // Prints 0
  /// ```
  /// Creates a new table dynamically generating cells via the `generator` callback.
  Int32Table.generate(
    int rows,
    int columns,
    int Function(int row, int col) generator,
  )   : assert(rows >= 0, 'rows must be non-negative'),
        assert(columns >= 0, 'columns must be non-negative'),
        _rows = rows,
        _columns = columns,
        _data = Int32List(rows * columns) {
    int index = 0;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < columns; c++) {
        _data[index++] = generator(r, c);
      }
    }
  }

  /// Validates that the provided [row] and [col] indices are within the grid dimensions.
  ///
  /// Throws a [RangeError] if the indices are out of bounds.
  void _checkBounds(int row, int col) {
    if (_rows == 0) {
      throw RangeError('Table has 0 rows; index $row is out of bounds.');
    }
    if (_columns == 0) {
      throw RangeError('Table has 0 columns; index $col is out of bounds.');
    }
    if (row < 0 || row >= _rows) {
      throw RangeError.range(row, 0, _rows - 1, 'row');
    }
    if (col < 0 || col >= _columns) {
      throw RangeError.range(col, 0, _columns - 1, 'col');
    }
  }

  /// Retrieves the element at the specified [row] and [col].
  ///
  /// Returns the 32-bit integer currently stored at the given coordinates.
  ///
  /// Throws a [RangeError] if [row] is less than 0 or greater than or equal
  /// to [rows], or if [col] is less than 0 or greater than or equal to [columns].
  /// Also throws a [RangeError] if the table is completely empty (0 rows or 0 columns).
  ///
  /// Example:
  /// ```dart
  /// final table = Int32Table.filled(2, 2, 99);
  /// int val = table.get(0, 0); // val is 99
  /// ```
  int get(int row, int col) {
    _checkBounds(row, col);
    return _data[(row * _columns) + col];
  }

  /// Sets the [value] at the specified [row] and [col].
  ///
  /// Replaces the existing element at the given coordinates with the new [value].
  ///
  /// Throws a [RangeError] if [row] is less than 0 or greater than or equal
  /// to [rows], or if [col] is less than 0 or greater than or equal to [columns].
  /// Also throws a [RangeError] if the table is completely empty (0 rows or 0 columns).
  ///
  /// Example:
  /// ```dart
  /// final table = Int32Table.filled(2, 2, 0);
  /// table.set(1, 1, 42);
  /// print(table.get(1, 1)); // Prints 42
  /// ```
  void set(int row, int col, int value) {
    _checkBounds(row, col);
    _data[(row * _columns) + col] = value;
  }
}
