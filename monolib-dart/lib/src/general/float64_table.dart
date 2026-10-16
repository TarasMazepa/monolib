/// A high-performance, dense 2D data structure backed by a single flat [Float64List].
///
/// This structure guarantees memory contiguity for 64-bit floating point numbers,
/// eliminates pointer indirection, and maximizes CPU cache locality, making it
/// well-suited for high-frequency mathematical operations and data matrices.
library;

import 'dart:typed_data';

/// A specialized, high-performance dense 2-dimensional data structure for 64-bit floating point numbers.
///
/// Unlike standard `List<List<double>>` which suffers from memory fragmentation and pointer
/// indirection, [Float64Table] is backed by a single contiguous [Float64List]. This
/// architectural choice guarantees raw C-level performance and maximum CPU cache locality,
/// optimizing high-throughput numerical processing (e.g., matrix math, sensor data grids).
///
/// Elements are mapped to the 1-dimensional array using row-major order via the
/// formula `(row * columns) + col`.
class Float64Table {
  final Float64List _data;
  final int _rows;
  final int _columns;

  /// The total number of horizontal rows in the table.
  int get rows => _rows;

  /// The total number of vertical columns in the table.
  int get columns => _columns;

  /// Allocates a dense table with the specified number of [rows] and [columns],
  /// initializing all elements to the specified [fillValue].
  ///
  /// This constructor is optimized by using native memory fill operations.
  /// If either [rows] or [columns] is 0, an empty table is instantiated safely.
  ///
  /// Both parameters must be non-negative.
  ///
  /// **Example:**
  /// ```dart
  /// // Create a 2x2 matrix filled with zeros
  /// final matrix = Float64Table.filled(2, 2, 0.0);
  /// ```
  Float64Table.filled(int rows, int columns, double fillValue)
    : assert(rows >= 0, 'rows must be non-negative'),
      assert(columns >= 0, 'columns must be non-negative'),
      _rows = rows,
      _columns = columns,
      _data = Float64List(rows * columns)
        ..fillRange(0, rows * columns, fillValue);

  /// Allocates a dense table with the specified [rows] and [columns],
  /// generating values dynamically using the [generator] callback.
  ///
  /// The [generator] is invoked iteratively for every valid `(row, col)` coordinate,
  /// traversing the grid in row-major order.
  ///
  /// Both parameters must be non-negative.
  ///
  /// **Example:**
  /// ```dart
  /// // Create a 3x3 identity matrix
  /// final identity = Float64Table.generate(3, 3, (row, col) => row == col ? 1.0 : 0.0);
  /// ```
  Float64Table.generate(
    int rows,
    int columns,
    double Function(int row, int col) generator,
  ) : assert(rows >= 0, 'rows must be non-negative'),
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

  /// Ensures that the provided [row] and [col] coordinate exists within the current table boundaries.
  ///
  /// Throws a [RangeError] if the indices are out of bounds, preventing invalid memory access
  /// on the underlying [Float64List].
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

  /// Retrieves the 64-bit float located at the precise [row] and [col] coordinate.
  ///
  /// This operation performs a constant-time lookup by converting the 2D coordinate
  /// into a 1D flat index using row-major ordering.
  ///
  /// Throws a [RangeError] if [row] or [col] exceed the table's constraints.
  double get(int row, int col) {
    _checkBounds(row, col);
    return _data[(row * _columns) + col];
  }

  /// Overwrites the cell at the precise [row] and [col] coordinate with the new [value].
  ///
  /// This operation mutates the underlying [Float64List] in constant time after converting
  /// the 2D coordinate into a 1D flat index using row-major ordering.
  ///
  /// Throws a [RangeError] if [row] or [col] exceed the table's constraints.
  void set(int row, int col, double value) {
    _checkBounds(row, col);
    _data[(row * _columns) + col] = value;
  }
}
