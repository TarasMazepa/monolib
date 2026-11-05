import 'dart:async';

import 'package:monolib_dart/jsonl.dart';
import 'package:test/test.dart';

class _FailingItem {
  dynamic toJson() => throw Exception('serialization error');
}

class _RecordingStringSink implements StringSink {
  final List<String> writes = [];

  @override
  void write(Object? object) {
    writes.add('$object');
  }

  @override
  void writeAll(Iterable<dynamic> objects, [String separator = '']) {
    writes.add(objects.join(separator));
  }

  @override
  void writeCharCode(int charCode) {
    writes.add(String.fromCharCode(charCode));
  }

  @override
  void writeln([Object? object = '']) {
    writes.add('$object\n');
  }
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

    test('resolves Future items', () async {
      final buffer = StringBuffer();
      final items = [
        Future.value({'async': true}),
        {'sync': true},
      ];

      await jsonlEncodeAsync(items: items, sink: buffer);

      expect(buffer.toString(), '{"async":true}\n{"sync":true}\n');
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

    test(
      'flushes prior buffered writes before awaiting delayed item',
      () async {
        final completer = Completer<Map<String, dynamic>>();
        final sink = _RecordingStringSink();
        final items = [
          {'id': 1},
          completer.future,
        ];

        final future = jsonlEncodeAsync(items: items, sink: sink);
        await Future<void>.delayed(Duration.zero);

        expect(sink.writes.join(), '{"id":1}\n');

        completer.complete({'id': 2});
        await future;

        expect(sink.writes.join(), '{"id":1}\n{"id":2}\n');
      },
    );

    test('does not invoke sinkProvider when stream yields no items', () async {
      bool created = false;
      await jsonlEncodeAsync(
        items: Stream.empty(),
        sinkProvider: () {
          created = true;
          return _RecordingStringSink();
        },
      );

      expect(created, isFalse);
    });
  });
}
