import 'dart:io';

void main() {
  final files = [
    'monolib-dart/lib/src/general/dense_table.dart',
    'monolib-dart/lib/src/general/float64_table.dart',
    'monolib-dart/lib/src/general/int32_table.dart',
  ];

  for (final path in files) {
    final file = File(path);
    var content = file.readAsStringSync();

    if (path.contains('dense_table.dart')) {
      content = content.replaceAll(
        '  /// Ensures that the requested [row] and [col] coordinates fall within valid table boundaries.\n  /// Validates that the provided [row] and [col] indices are within the grid dimensions.\n  ///\n  /// Throws a [RangeError] if the indices are out of bounds.\n  void _checkBounds(int row, int col) {',
        '  /// Validates that the provided [row] and [col] indices are within the grid dimensions.\n  ///\n  /// Throws a [RangeError] if the indices are out of bounds.\n  void _checkBounds(int row, int col) {'
      );
    } else if (path.contains('float64_table.dart')) {
        content = content.replaceAll(
        '  /// Ensures that the provided [row] and [col] coordinate exists within the current table boundaries.\n  ///\n  /// Throws a [RangeError] if the indices are out of bounds, preventing invalid memory access\n  /// on the underlying [Float64List].\n  /// Validates that the provided [row] and [col] indices are within the grid dimensions.\n  ///\n  /// Throws a [RangeError] if the indices are out of bounds.\n  void _checkBounds(int row, int col) {',
        '  /// Validates that the provided [row] and [col] indices are within the grid dimensions.\n  ///\n  /// Throws a [RangeError] if the indices are out of bounds.\n  void _checkBounds(int row, int col) {'
      );
    } else if (path.contains('int32_table.dart')) {
      content = content.replaceAll(
        '  /// Ensures that the provided [row] and [col] are within the bounds of the table.\n  /// Validates that the provided [row] and [col] indices are within the grid dimensions.\n  ///\n  /// Throws a [RangeError] if the indices are out of bounds.\n  void _checkBounds(int row, int col) {',
        '  /// Validates that the provided [row] and [col] indices are within the grid dimensions.\n  ///\n  /// Throws a [RangeError] if the indices are out of bounds.\n  void _checkBounds(int row, int col) {'
      );
    }

    file.writeAsStringSync(content);
  }
}
