import 'dart:async';

import 'package:monolib_dart/csv.dart';
import 'package:test/test.dart';

void main() {
  group('csvEncodeAsync', () {
    test('encodes Iterable correctly', () async {
      final items = [
        ['a', 'b', 'c'],
        ['1', '2', '3'],
        ['"quoted"', 'newline\n', 'comma,'],
      ];
      final buffer = StringBuffer();
      await csvEncodeAsync(items: items, sink: buffer);
      expect(
        buffer.toString(),
        'a,b,c\r\n1,2,3\r\n"""quoted""","newline\n","comma,"\r\n',
      );
    });

    test('encodes Stream correctly', () async {
      final items = Stream.fromIterable([
        ['a', 'b', 'c'],
        ['1', '2', '3'],
        ['"quoted"', 'newline\n', 'comma,'],
      ]);
      final buffer = StringBuffer();
      await csvEncodeAsync(items: items, sink: buffer);
      expect(
        buffer.toString(),
        'a,b,c\r\n1,2,3\r\n"""quoted""","newline\n","comma,"\r\n',
      );
    });

    test('handles futures in iterables and cells', () async {
      final items = [
        Future.value(['a', 'b', Future.value('c')]),
        ['1', '2', '3'],
      ];
      final buffer = StringBuffer();
      await csvEncodeAsync(items: items, sink: buffer);
      expect(buffer.toString(), 'a,b,c\r\n1,2,3\r\n');
    });

    test('throws ArgumentError for invalid input', () async {
      final buffer = StringBuffer();
      expect(
        () => csvEncodeAsync(items: 'invalid', sink: buffer),
        throwsArgumentError,
      );
    });
    test(
      'throws ArgumentError if both sink and sinkProvider are provided',
      () async {
        final buffer = StringBuffer();
        expect(
          () => csvEncodeAsync(
            items: [],
            sink: buffer,
            sinkProvider: () => buffer,
          ),
          throwsArgumentError,
        );
      },
    );

    test(
      'throws ArgumentError if neither sink nor sinkProvider is provided',
      () async {
        expect(() => csvEncodeAsync(items: []), throwsArgumentError);
      },
    );

    test('uses sinkProvider and closes the sink', () async {
      final items = [
        ['a', 'b', 'c'],
        ['1', '2', '3'],
      ];
      final sink = _TestSink();
      await csvEncodeAsync(items: items, sinkProvider: () => sink);

      expect(sink.buffer.toString(), 'a,b,c\r\n1,2,3\r\n');
      expect(sink.isClosed, isTrue);
    });

    test('uses sink directly and does not close it', () async {
      final items = [
        ['a', 'b', 'c'],
        ['1', '2', '3'],
      ];
      final sink = _TestSink();
      await csvEncodeAsync(items: items, sink: sink);

      expect(sink.buffer.toString(), 'a,b,c\r\n1,2,3\r\n');
      expect(sink.isClosed, isFalse);
    });

    test(
      'flushes prior buffered writes before awaiting delayed row or cell',
      () async {
        final completer = Completer<List<dynamic>>();
        final sink = _TestSink();
        final items = [
          ['sync1', 'sync2'],
          completer.future,
        ];

        final future = csvEncodeAsync(items: items, sink: sink);
        await Future<void>.delayed(Duration.zero);

        expect(sink.buffer.toString(), 'sync1,sync2\r\n');

        completer.complete(['async1', 'async2']);
        await future;

        expect(sink.buffer.toString(), 'sync1,sync2\r\nasync1,async2\r\n');
      },
    );

    test('does not invoke sinkProvider when stream yields no items', () async {
      bool created = false;
      await csvEncodeAsync(
        items: Stream.empty(),
        sinkProvider: () {
          created = true;
          return _TestSink();
        },
      );

      expect(created, isFalse);
    });
  });
}

class _TestSink implements Sink<String>, StringSink {
  final buffer = StringBuffer();
  bool isClosed = false;

  @override
  void add(String data) {
    buffer.write(data);
  }

  @override
  void close() {
    isClosed = true;
  }

  @override
  void write(Object? object) {
    buffer.write(object);
  }

  @override
  void writeAll(Iterable objects, [String separator = ""]) {
    buffer.writeAll(objects, separator);
  }

  @override
  void writeCharCode(int charCode) {
    buffer.writeCharCode(charCode);
  }

  @override
  void writeln([Object? object = ""]) {
    buffer.writeln(object);
  }
}
