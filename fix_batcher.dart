import 'dart:io';

void main() {
  final file = File('monolib-dart/lib/src/general/batcher.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll(
    'class Batcher<T> {',
    '/// An architectural primitive for aggregating synchronous, high-frequency events into periodic asynchronous chunks.\nclass Batcher<T> {'
  );
  file.writeAsStringSync(content);
}
