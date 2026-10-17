import 'dart:io';

void main() {
  var file = File('monolib-dart/lib/src/general/dense_table.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll(
    '  void _checkBounds(int row, int col) {',
    '  /// Validates that the provided [row] and [col] indices are within the grid dimensions.\n  ///\n  /// Throws a [RangeError] if the indices are out of bounds.\n  void _checkBounds(int row, int col) {'
  );
  file.writeAsStringSync(content);

  file = File('monolib-dart/lib/src/general/float64_table.dart');
  content = file.readAsStringSync();
  content = content.replaceAll(
    '  void _checkBounds(int row, int col) {',
    '  /// Validates that the provided [row] and [col] indices are within the grid dimensions.\n  ///\n  /// Throws a [RangeError] if the indices are out of bounds.\n  void _checkBounds(int row, int col) {'
  );
  file.writeAsStringSync(content);

  file = File('monolib-dart/lib/src/general/int32_table.dart');
  content = file.readAsStringSync();
  content = content.replaceAll(
    '  void _checkBounds(int row, int col) {',
    '  /// Validates that the provided [row] and [col] indices are within the grid dimensions.\n  ///\n  /// Throws a [RangeError] if the indices are out of bounds.\n  void _checkBounds(int row, int col) {'
  );
  file.writeAsStringSync(content);

  file = File('monolib-dart/lib/src/general/on_list.dart');
  content = file.readAsStringSync();
  content = content.replaceAll(
    '  List<E> toIndexedMappedList<E>(',
    '  /// Eagerly converts the list to a new mapped [List], providing the current [index] to the [mapper].\n  ///\n  /// Avoids the overhead of `asMap().entries.map(...)` by directly utilizing a\n  /// [List.generate] loop. Useful for index-aware transformations.\n  ///\n  /// The [growable] parameter dictates whether the newly created list can change length.\n  ///\n  /// ```dart\n  /// final widgets = items.toIndexedMappedList((item, index) {\n  ///   return buildItem(item, isFirst: index == 0);\n  /// });\n  /// ```\n  List<E> toIndexedMappedList<E>('
  );
  // Remove the old comment that is detached
  content = content.replaceAll(
    '  /// Eagerly converts the list to a new mapped [List], providing the current [index] to the [mapper].\n  ///\n  /// Avoids the overhead of `asMap().entries.map(...)` by directly utilizing a\n  /// [List.generate] loop. Useful for index-aware transformations.\n  ///\n  /// The [growable] parameter dictates whether the newly created list can change length.\n  ///\n  /// ```dart\n  /// final widgets = items.toIndexedMappedList((item, index) {\n  ///   return buildItem(item, isFirst: index == 0);\n  /// });\n  /// ```\n  List<E> toIndexedMappedList<E>(',
    '  List<E> toIndexedMappedList<E>(' // Temporary removal to fix duplicate
  );
  file.writeAsStringSync(content);
}
