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

    content = content.replaceAll(
      '  Float64Table.generate(',
      '  /// Creates a new table dynamically generating cells via the `generator` callback.\n  Float64Table.generate('
    );
    content = content.replaceAll(
      '  Int32Table.generate(',
      '  /// Creates a new table dynamically generating cells via the `generator` callback.\n  Int32Table.generate('
    );
    file.writeAsStringSync(content);
  }
}
