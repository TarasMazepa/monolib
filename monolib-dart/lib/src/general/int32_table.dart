import 'dart:typed_data';

/// A specialized, high-performance dense 2D data structure for 32-bit integers.
///
/// Backed by a [Int32List] for raw C-level performance, memory contiguity,
/// and maximum CPU cache locality.
class Int32Table {
  final Int32List _data;
  final int _rows;
  final int _columns;

  /// The number of rows in the table.
  int get rows => _rows;

  /// The number of columns in the table.
  int get columns => _columns;

  /// Creates a dense table with the given number of [rows] and [columns],
  /// filled with [fillValue].
  Int32Table.filled(int rows, int columns, int fillValue)
      : _rows = rows,
        _columns = columns,
        _data = Int32List(rows * columns)
          ..fillRange(0, rows * columns, fillValue);

  /// Creates a dense table with the given number of [rows] and [columns],
  /// generating values dynamically using the [generator] function.
  Int32Table.generate(
      int rows, int columns, int Function(int row, int col) generator)
      : _rows = rows,
        _columns = columns,
        _data = Int32List(rows * columns) {
    for (int i = 0; i < _data.length; i++) {
      final int row = i ~/ columns;
      final int col = i % columns;
      _data[i] = generator(row, col);
    }
  }

  /// Ensures that the provided [row] and [col] are within the bounds of the table.
  void _checkBounds(int row, int col) {
    if (row < 0 || row >= _rows) {
      throw RangeError.range(row, 0, _rows - 1, 'row');
    }
    if (col < 0 || col >= _columns) {
      throw RangeError.range(col, 0, _columns - 1, 'col');
    }
  }

  /// Retrieves the element at the specified [row] and [col].
  ///
  /// Throws a [RangeError] if [row] or [col] are out of bounds.
  int get(int row, int col) {
    _checkBounds(row, col);
    return _data[(row * _columns) + col];
  }

  /// Sets the [value] at the specified [row] and [col].
  ///
  /// Throws a [RangeError] if [row] or [col] are out of bounds.
  void set(int row, int col, int value) {
    _checkBounds(row, col);
    _data[(row * _columns) + col] = value;
  }
}
