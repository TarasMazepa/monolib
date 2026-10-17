/// A high-performance, dense 2D data structure backed by a single flat list.
///
/// This guarantees memory contiguity, eliminates pointer indirection,
/// and maximizes CPU cache locality.
library;

/// A high-performance, dense 2-dimensional tabular data structure backed by a single flat array.
///
/// Unlike typical `List<List<T>>` implementations which suffer from pointer indirection
/// and memory fragmentation, [DenseTable] allocates contiguous memory by flattening
/// two-dimensional coordinates into a single 1-dimensional [List]. This design
/// maximizes CPU cache locality, drastically improving read/write iteration
/// performance for data-heavy operations like game grids, pixel buffers, or mathematical matrices.
///
/// Elements are stored in row-major order, mapped using the formula `(row * columns) + col`.
///
/// **Example usage:**
/// ```dart
/// // Create a 3x3 grid initialized to 0
/// final grid = DenseTable<int>.filled(3, 3, 0);
///
/// // Update the center element
/// grid.set(1, 1, 99);
///
/// // Retrieve the top-right element
/// final val = grid.get(0, 2);
/// ```
class DenseTable<T> {
  final List<T> _data;
  final int _rows;
  final int _columns;

  /// The total number of horizontal rows in the [DenseTable].
  int get rows => _rows;

  /// The total number of vertical columns in the [DenseTable].
  int get columns => _columns;

  /// Allocates a new [DenseTable] with the specified dimensions, initializing all cells to [fillValue].
  ///
  /// This is the most efficient constructor, relying on a single native array fill operation.
  ///
  /// Both [rows] and [columns] must be non-negative.
  DenseTable.filled(int rows, int columns, T fillValue)
      : assert(rows >= 0, 'rows must be non-negative'),
        assert(columns >= 0, 'columns must be non-negative'),
        _rows = rows,
        _columns = columns,
        _data = List<T>.filled(rows * columns, fillValue);

  /// Allocates a new [DenseTable], populating cells dynamically via the [generator] callback.
  ///
  /// The [generator] is invoked for every valid `(row, col)` coordinate pair in row-major order.
  /// To optimize instantiation overhead, this avoids modulo/division arithmetic,
  /// instead utilizing nested counters to determine the current coordinate.
  ///
  /// Both [rows] and [columns] must be non-negative.
  DenseTable.generate(
    int rows,
    int columns,
    T Function(int row, int col) generator,
  )   : assert(rows >= 0, 'rows must be non-negative'),
        assert(columns >= 0, 'columns must be non-negative'),
        _rows = rows,
        _columns = columns,
        _data = (() {
          int r = 0;
          int c = 0;
          return List<T>.generate(rows * columns, (_) {
            final value = generator(r, c);
            c++;
            if (c == columns) {
              c = 0;
              r++;
            }
            return value;
          }, growable: false);
        })();

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

  /// Retrieves the element located at the precise [row] and [col] coordinate.
  ///
  /// Resolves the 2D coordinate to its 1D internal index in row-major order.
  ///
  /// Throws a [RangeError] if [row] or [col] exceed [rows] or [columns] constraints.
  T get(int row, int col) {
    _checkBounds(row, col);
    return _data[(row * _columns) + col];
  }

  /// Overwrites the cell at the precise [row] and [col] coordinate with [value].
  ///
  /// Maps the 2D coordinate to its 1D internal array index and mutates the element in-place.
  ///
  /// Throws a [RangeError] if [row] or [col] exceed [rows] or [columns] constraints.
  void set(int row, int col, T value) {
    _checkBounds(row, col);
    _data[(row * _columns) + col] = value;
  }
}
