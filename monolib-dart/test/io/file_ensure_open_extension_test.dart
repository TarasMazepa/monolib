import 'dart:io';

import 'package:monolib_dart/io.dart';
import 'package:test/test.dart';

void main() {
  group('FileEnsureOpenExtension', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp(
        'file_ensure_open_extension_test',
      );
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test(
      'openWriteEnsureParent creates parent directories and returns writable sink',
      () async {
        final deeplyNestedDir = Directory('${tempDir.path}/a/b/c/d');
        final file = File('${deeplyNestedDir.path}/test_file.txt');

        expect(await deeplyNestedDir.exists(), isFalse);
        expect(await file.exists(), isFalse);

        final sink = await file.openWriteEnsureParent();

        expect(await deeplyNestedDir.exists(), isTrue);

        const content = 'Hello, world!';
        sink.write(content);
        await sink.close();

        expect(await file.exists(), isTrue);

        final readContent = await file.readAsString();
        expect(readContent, content);
      },
    );
  });
}
