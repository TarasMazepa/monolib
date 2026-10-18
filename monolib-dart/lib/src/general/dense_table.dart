/// A dense two-dimensional table of elements of type [T] backed by a single
/// flat [List].
///
/// Stores elements in row-major order at index `(row * columns) + col`,
/// avoiding the nested allocations and pointer indirection of a
/// `List<List<T>>`.
///
/// Example:
/// ```dart
/// final table = DenseTable<int>.filled(3, 3, 0);
/// table.set(1, 1, 99);
/// print(table.get(1, 1)); // 99
/// ```
class DenseTable<T> {
  final List<T> _data;
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
  /// final table = DenseTable<int>.filled(2, 3, 0);
  /// ```
  DenseTable.filled(int rows, int columns, T fillValue)
      : assert(rows >= 0, 'rows must be non-negative'),
        assert(columns >= 0, 'columns must be non-negative'),
        _rows = rows,
        _columns = columns,
        _data = List<T>.filled(rows * columns, fillValue);

  /// Creates a table with the given number of [rows] and [columns], populating
  /// each cell in row-major order using [generator].
  ///
  /// Both [rows] and [columns] must be non-negative.
  ///
  /// Example:
  /// ```dart
  /// final identity = DenseTable<int>.generate(
  ///   3,
  ///   3,
  ///   (row, col) => row == col ? 1 : 0,
  /// );
  /// ```
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
  T get(int row, int col) {
    _checkBounds(row, col);
    return _data[(row * _columns) + col];
  }

  /// Sets the element at [row] and [col] to [value].
  ///
  /// Throws a [RangeError] if [row] or [col] is out of bounds.
  void set(int row, int col, T value) {
    _checkBounds(row, col);
    _data[(row * _columns) + col] = value;
  }
}
