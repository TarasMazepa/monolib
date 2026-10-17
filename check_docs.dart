import 'dart:io';

void main() {
  final dir = Directory('monolib-dart/lib/src/general');
  final files = dir.listSync().whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    final lines = file.readAsLinesSync();
    int lineNum = 0;
    for (final line in lines) {
      lineNum++;
      if ((line.startsWith('class ') || line.startsWith('extension ') || line.startsWith('mixin ')) && !line.startsWith('class _')) {
        // check if previous line has ///
        if (lineNum > 1 && !lines[lineNum - 2].trim().startsWith('///')) {
          print('Missing doc for class/extension in ${file.path}:${lineNum}');
        }
      }
      // rough check for public methods/properties
      if (line.contains(RegExp(r'^\s+(String|int|double|bool|void|List|Map|Iterable|Future|Stream|T|R)\s+[a-zA-Z0-9_]+\('))) {
        if (!line.contains('_') && lineNum > 1 && !lines[lineNum - 2].trim().startsWith('///') && !lines[lineNum - 2].trim().startsWith('@override')) {
           print('Missing doc for method in ${file.path}:${lineNum}');
        }
      }
    }
  }
}
