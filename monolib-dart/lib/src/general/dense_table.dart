/// A high-performance, dense 2D data structure backed by a single flat list.
///
/// This guarantees memory contiguity, eliminates pointer indirection,
/// and maximizes CPU cache locality.
class DenseTable<T> {
  final List<T> _data;
  final int _rows;
  final int _columns;

  /// The number of rows in the table.
  int get rows => _rows;

  /// The number of columns in the table.
  int get columns => _columns;

  /// Creates a dense table with the given number of [rows] and [columns],
  /// filled with [fillValue].
  DenseTable.filled(int rows, int columns, T fillValue)
    : assert(rows >= 0, 'rows must be non-negative'),
      assert(columns >= 0, 'columns must be non-negative'),
      _rows = rows,
      _columns = columns,
      _data = List<T>.filled(rows * columns, fillValue);

  /// Creates a dense table with the given number of [rows] and [columns],
  /// generating values dynamically using the [generator] function.
  DenseTable.generate(
    int rows,
    int columns,
    T Function(int row, int col) generator,
  ) : assert(rows >= 0, 'rows must be non-negative'),
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

  /// Ensures that the provided [row] and [col] are within the bounds of the table.
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
  /// Throws a [RangeError] if [row] or [col] are out of bounds.
  T get(int row, int col) {
    _checkBounds(row, col);
    return _data[(row * _columns) + col];
  }

  /// Sets the [value] at the specified [row] and [col].
  ///
  /// Throws a [RangeError] if [row] or [col] are out of bounds.
  void set(int row, int col, T value) {
    _checkBounds(row, col);
    _data[(row * _columns) + col] = value;
  }
}
