import 'dart:io';

void main() {
  var file = File('monolib-dart/lib/src/general/dense_table.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll(
    '  /// Ensures that the requested [row] and [col] coordinates fall within valid table boundaries.\n  /// Validates that the provided [row] and [col] indices are within the grid dimensions.\n  ///\n  /// Throws a [RangeError] if the indices are out of bounds.\n  void _checkBounds(int row, int col) {',
    '  /// Validates that the provided [row] and [col] indices are within the grid dimensions.\n  ///\n  /// Throws a [RangeError] if the indices are out of bounds.\n  void _checkBounds(int row, int col) {'
  );
  file.writeAsStringSync(content);
}
