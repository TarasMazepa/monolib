import 'dart:async';

import 'package:monolib_dart/csv.dart';
import 'package:test/test.dart';

void main() {
  group('csvEncodeBatchAsync', () {
    test('encodes Stream of batches correctly', () async {
      final batches = Stream.fromIterable([
        [
          ['a', 'b', 'c'],
          ['1', '2', '3'],
        ],
        [
          ['"quoted"', 'newline\n', 'comma,'],
        ],
      ]);
      final buffer = StringBuffer();
      await csvEncodeBatchAsync(batches: batches, sink: buffer);
      expect(
        buffer.toString(),
        'a,b,c\r\n1,2,3\r\n"""quoted""","newline\n","comma,"\r\n',
      );
    });

    test('throws ArgumentError for missing sink arguments', () async {
      final batches = Stream.fromIterable([<List<String>>[]]);
      expect(() => csvEncodeBatchAsync(batches: batches), throwsArgumentError);
    });

    test(
      'throws ArgumentError if both sink and sinkProvider are provided',
      () async {
        final batches = Stream.fromIterable([<List<String>>[]]);
        final buffer = StringBuffer();
        expect(
          () => csvEncodeBatchAsync(
            batches: batches,
            sink: buffer,
            sinkProvider: () => buffer,
          ),
          throwsArgumentError,
        );
      },
    );

    test('uses sinkProvider and closes the sink', () async {
      final batches = Stream.fromIterable([
        [
          ['a', 'b', 'c'],
          ['1', '2', '3'],
        ],
      ]);
      final sink = _TestSink();
      await csvEncodeBatchAsync(batches: batches, sinkProvider: () => sink);

      expect(sink.buffer.toString(), 'a,b,c\r\n1,2,3\r\n');
      expect(sink.isClosed, isTrue);
    });

    test('uses sink directly and does not close it', () async {
      final batches = Stream.fromIterable([
        [
          ['a', 'b', 'c'],
          ['1', '2', '3'],
        ],
      ]);
      final sink = _TestSink();
      await csvEncodeBatchAsync(batches: batches, sink: sink);

      expect(sink.buffer.toString(), 'a,b,c\r\n1,2,3\r\n');
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
