import 'dart:typed_data';

/// A dense two-dimensional table of 32-bit integers backed by a single flat
/// [Int32List].
///
/// Stores elements in row-major order at index `(row * columns) + col`,
/// avoiding the nested allocations and pointer indirection of a
/// `List<List<int>>`.
///
/// Example:
/// ```dart
/// final table = Int32Table.filled(3, 3, 0);
/// table.set(1, 1, 42);
/// print(table.get(1, 1)); // 42
/// ```
class Int32Table {
  final Int32List _data;
  final int _rows;
  final int _columns;

  /// The number of rows in the table.
  int get rows => _rows;

  /// The number of columns in the table.
  int get columns => _columns;

  /// Creates a table with the given number of [rows] and [columns],
  /// initializing every cell to [fillValue].
  ///
  /// Both [rows] and [columns] must be non-negative.
  ///
  /// Example:
  /// ```dart
  /// final table = Int32Table.filled(2, 3, 7);
  /// ```
  Int32Table.filled(int rows, int columns, int fillValue)
      : assert(rows >= 0, 'rows must be non-negative'),
        assert(columns >= 0, 'columns must be non-negative'),
        _rows = rows,
        _columns = columns,
        _data = Int32List(rows * columns)
          ..fillRange(0, rows * columns, fillValue);

  /// Creates a table with the given number of [rows] and [columns], populating
  /// each cell in row-major order using [generator].
  ///
  /// Both [rows] and [columns] must be non-negative.
  ///
  /// Example:
  /// ```dart
  /// final identity = Int32Table.generate(
  ///   3,
  ///   3,
  ///   (row, col) => row == col ? 1 : 0,
  /// );
  /// ```
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

  /// Returns the element at [row] and [col].
  ///
  /// Throws a [RangeError] if [row] or [col] is out of bounds.
  int get(int row, int col) {
    _checkBounds(row, col);
    return _data[(row * _columns) + col];
  }

  /// Sets the element at [row] and [col] to [value].
  ///
  /// Throws a [RangeError] if [row] or [col] is out of bounds.
  void set(int row, int col, int value) {
    _checkBounds(row, col);
    _data[(row * _columns) + col] = value;
  }
}
