import 'dart:async';

import 'package:monolib_dart/jsonl.dart';
import 'package:test/test.dart';

class _FailingItem {
  dynamic toJson() => throw Exception('serialization error');
}

void main() {
  group('jsonlEncodeBatchAsync', () {
    test('encodes stream of batches with trailing newlines', () async {
      final batches = Stream.fromIterable([
        [
          {'id': 1},
          {'id': 2},
        ],
        [
          {'id': 3},
        ]
      ]);
      final buffer = StringBuffer();
      await jsonlEncodeBatchAsync(batches: batches, sink: buffer);

      expect(buffer.toString(), '{"id":1}\n{"id":2}\n{"id":3}\n');
    });

    test('throws ArgumentError for missing sink arguments', () async {
      final batches = Stream.fromIterable([<List<int>>[]]);
      expect(
        () => jsonlEncodeBatchAsync(batches: batches),
        throwsArgumentError,
      );
    });

    test('throws ArgumentError if both sink and sinkProvider are provided',
        () async {
      final batches = Stream.fromIterable([<List<int>>[]]);
      final buffer = StringBuffer();
      expect(
        () => jsonlEncodeBatchAsync(
          batches: batches,
          sink: buffer,
          sinkProvider: () => buffer,
        ),
        throwsArgumentError,
      );
    });

    test('writes newline in finally block when stream item encoding fails',
        () async {
      final batches = Stream.fromIterable([
        [_FailingItem()]
      ]);
      final buffer = StringBuffer();

      await expectLater(
        () => jsonlEncodeBatchAsync(batches: batches, sink: buffer),
        throwsA(isA<Exception>()),
      );

      // The sink should still receive a newline from the finally block of the inner jsonlEncodeAsync
      expect(buffer.toString(), '\n');
    });

    test('uses sinkProvider and closes the sink', () async {
      final batches = Stream.fromIterable([
        [
          {'id': 1},
          {'id': 2},
        ]
      ]);
      final sink = _TestSink();
      await jsonlEncodeBatchAsync(batches: batches, sinkProvider: () => sink);

      expect(sink.buffer.toString(), '{"id":1}\n{"id":2}\n');
      expect(sink.isClosed, isTrue);
    });

    test('uses sink directly and does not close it', () async {
      final batches = Stream.fromIterable([
        [
          {'id': 1},
          {'id': 2},
        ]
      ]);
      final sink = _TestSink();
      await jsonlEncodeBatchAsync(batches: batches, sink: sink);

      expect(sink.buffer.toString(), '{"id":1}\n{"id":2}\n');
      expect(sink.isClosed, isFalse);
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
