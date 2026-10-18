import 'dart:typed_data';

/// A dense two-dimensional table of 64-bit floating-point numbers backed by a
/// single flat [Float64List].
///
/// Stores elements in row-major order at index `(row * columns) + col`,
/// avoiding the nested allocations and pointer indirection of a
/// `List<List<double>>`.
///
/// Example:
/// ```dart
/// final table = Float64Table.filled(3, 3, 0.0);
/// table.set(1, 1, 99.5);
/// print(table.get(1, 1)); // 99.5
/// ```
class Float64Table {
  final Float64List _data;
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
  /// final table = Float64Table.filled(2, 3, 0.0);
  /// ```
  Float64Table.filled(int rows, int columns, double fillValue)
      : assert(rows >= 0, 'rows must be non-negative'),
        assert(columns >= 0, 'columns must be non-negative'),
        _rows = rows,
        _columns = columns,
        _data = Float64List(rows * columns)
          ..fillRange(0, rows * columns, fillValue);

  /// Creates a table with the given number of [rows] and [columns], populating
  /// each cell in row-major order using [generator].
  ///
  /// Both [rows] and [columns] must be non-negative.
  ///
  /// Example:
  /// ```dart
  /// final identity = Float64Table.generate(
  ///   3,
  ///   3,
  ///   (row, col) => row == col ? 1.0 : 0.0,
  /// );
  /// ```
  Float64Table.generate(
    int rows,
    int columns,
    double Function(int row, int col) generator,
  )   : assert(rows >= 0, 'rows must be non-negative'),
        assert(columns >= 0, 'columns must be non-negative'),
        _rows = rows,
        _columns = columns,
        _data = Float64List(rows * columns) {
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
  double get(int row, int col) {
    _checkBounds(row, col);
    return _data[(row * _columns) + col];
  }

  /// Sets the element at [row] and [col] to [value].
  ///
  /// Throws a [RangeError] if [row] or [col] is out of bounds.
  void set(int row, int col, double value) {
    _checkBounds(row, col);
    _data[(row * _columns) + col] = value;
  }
}
