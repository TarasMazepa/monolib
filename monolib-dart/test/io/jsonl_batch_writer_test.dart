import 'dart:io';

import 'package:monolib_dart/io.dart';
import 'package:test/test.dart';

void main() {
  group('JsonlBatchWriter', () {
    late File file;
    late JsonlBatchWriter<Map<String, Object>> writer;

    setUp(() {
      file = File('test_jsonl_batch_writer.jsonl');
      if (file.existsSync()) {
        file.deleteSync();
      }
    });

    tearDown(() async {
      await writer.dispose();
      if (file.existsSync()) {
        file.deleteSync();
      }
    });

    test('does not create file if add() is never called', () async {
      writer = JsonlBatchWriter<Map<String, Object>>(
        file: file,
        maxBatchSize: 10,
        maxDuration: const Duration(milliseconds: 50),
      );

      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(file.existsSync(), isFalse);
    });

    test('writes batches when maxBatchSize is reached', () async {
      writer = JsonlBatchWriter<Map<String, Object>>(
        file: file,
        maxBatchSize: 2,
        maxDuration: const Duration(seconds: 10), // long enough to not trigger
      );

      writer.add(<String, Object>{'id': 1});
      writer.add(<String, Object>{'id': 2}); // This should trigger the write

      // Give it a tiny bit of time to execute async I/O
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(file.existsSync(), isTrue);

      final List<String> lines = file.readAsLinesSync();
      expect(lines.length, equals(2));
      expect(lines[0], equals('{"id":1}'));
      expect(lines[1], equals('{"id":2}'));
    });

    test('writes batches when maxDuration elapses', () async {
      writer = JsonlBatchWriter<Map<String, Object>>(
        file: file,
        maxBatchSize: 10, // large enough to not trigger
        maxDuration: const Duration(milliseconds: 50),
      );

      writer.add(<String, Object>{'id': 1});

      // Wait for duration to elapse
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(file.existsSync(), isTrue);

      final List<String> lines = file.readAsLinesSync();
      expect(lines.length, equals(1));
      expect(lines[0], equals('{"id":1}'));
    });

    test('dispose() safely drains buffer and closes sink', () async {
      writer = JsonlBatchWriter<Map<String, Object>>(
        file: file,
        maxBatchSize: 10, // large enough to not trigger
        maxDuration: const Duration(seconds: 10), // long enough to not trigger
      );

      writer.add(<String, Object>{'id': 1});
      writer.add(<String, Object>{'id': 2});

      await writer.dispose();

      expect(file.existsSync(), isTrue);

      final List<String> lines = file.readAsLinesSync();
      expect(lines.length, equals(2));
      expect(lines[0], equals('{"id":1}'));
      expect(lines[1], equals('{"id":2}'));
    });

    test('handles errors correctly via onError callback', () async {
      bool errorCalled = false;

      writer = JsonlBatchWriter<Map<String, Object>>(
        // This will fail because we can't write to a non-existent directory
        file: File('/non_existent_dir/test.jsonl'),
        maxBatchSize: 1,
        onError: (Object error, StackTrace st) {
          errorCalled = true;
        },
      );

      writer.add(<String, Object>{'id': 1}); // Triggers write and thus error

      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(errorCalled, isTrue);
    });
  });
}
