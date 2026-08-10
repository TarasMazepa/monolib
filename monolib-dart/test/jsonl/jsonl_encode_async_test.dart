import 'dart:async';

import 'package:monolib_dart/jsonl.dart';
import 'package:test/test.dart';

class _FailingItem {
  dynamic toJson() => throw Exception('serialization error');
}

void main() {
  group('jsonlEncodeAsync', () {
    test('encodes iterable of items with trailing newlines', () async {
      final items = [
        {'id': 1},
        {'id': 2},
      ];
      final buffer = StringBuffer();
      await jsonlEncodeAsync(items: items, sink: buffer);

      expect(buffer.toString(), '{"id":1}\n{"id":2}\n');
    });

    test('encodes stream of items with trailing newlines', () async {
      final stream = Stream.fromIterable([
        {'id': 1},
        {'id': 2},
      ]);
      final buffer = StringBuffer();
      await jsonlEncodeAsync(items: stream, sink: buffer);

      expect(buffer.toString(), '{"id":1}\n{"id":2}\n');
    });

    test(
      'writes newline in finally block when iterable item encoding fails',
      () async {
        final items = [_FailingItem()];
        final buffer = StringBuffer();

        await expectLater(
          () => jsonlEncodeAsync(items: items, sink: buffer),
          throwsA(isA<Exception>()),
        );

        // The sink should still receive a newline from the finally block
        expect(buffer.toString(), '\n');
      },
    );

    test(
      'writes newline in finally block when stream item encoding fails',
      () async {
        final stream = Stream.fromIterable([_FailingItem()]);
        final buffer = StringBuffer();

        await expectLater(
          () => jsonlEncodeAsync(items: stream, sink: buffer),
          throwsA(isA<Exception>()),
        );

        // The sink should still receive a newline from the finally block
        expect(buffer.toString(), '\n');
      },
    );
  });
}
