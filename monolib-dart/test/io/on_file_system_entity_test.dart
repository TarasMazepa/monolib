import 'dart:io';

import 'package:monolib_dart/io.dart';
import 'package:test/test.dart';

void main() {
  group('OnFileSystemEntity', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp(
        'on_file_system_entity_test_',
      );
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('deleteQuietly deletes an existing file', () async {
      final file = File('${tempDir.path}/test_file.txt');
      await file.create();
      expect(await file.exists(), isTrue);

      await file.deleteQuietly();
      expect(await file.exists(), isFalse);
    });

    test(
      'deleteQuietly does not throw when deleting a non-existent file',
      () async {
        final file = File('${tempDir.path}/non_existent_file.txt');
        expect(await file.exists(), isFalse);

        await expectLater(file.deleteQuietly(), completes);
      },
    );

    test('deleteQuietly deletes an empty directory', () async {
      final dir = Directory('${tempDir.path}/test_dir');
      await dir.create();
      expect(await dir.exists(), isTrue);

      await dir.deleteQuietly();
      expect(await dir.exists(), isFalse);
    });

    test(
      'deleteQuietly does not throw when deleting a non-existent directory',
      () async {
        final dir = Directory('${tempDir.path}/non_existent_dir');
        expect(await dir.exists(), isFalse);

        await expectLater(dir.deleteQuietly(), completes);
      },
    );

    test(
      'deleteQuietly without recursive: true does not throw when deleting a non-empty directory',
      () async {
        final dir = Directory('${tempDir.path}/test_dir_not_empty');
        await dir.create();
        final file = File('${dir.path}/test_file.txt');
        await file.create();

        // Deleting a non-empty directory without recursive: true would normally throw FileSystemException.
        // deleteQuietly should catch it and not throw.
        await expectLater(dir.deleteQuietly(), completes);

        // The directory should still exist since delete failed
        expect(await dir.exists(), isTrue);
      },
    );

    test(
      'deleteQuietly with recursive: true deletes a non-empty directory',
      () async {
        final dir = Directory('${tempDir.path}/test_dir_recursive');
        await dir.create();
        final file = File('${dir.path}/test_file.txt');
        await file.create();

        await dir.deleteQuietly(recursive: true);

        // The directory should be deleted
        expect(await dir.exists(), isFalse);
      },
    );
  });
}
