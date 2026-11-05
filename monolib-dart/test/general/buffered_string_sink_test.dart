import 'package:monolib_dart/src/common/buffered_string_sink.dart';
import 'package:test/test.dart';

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
  group('BufferedStringSink', () {
    test('buffers writes until flush is called', () {
      final sink = _RecordingStringSink();
      final buffered = BufferedStringSink(sink, maxBufferSize: 100);

      buffered.write('hello');
      buffered.write(' ');
      buffered.write('world');

      expect(sink.writes, isEmpty);
      expect(buffered.length, 11);
      expect(buffered.isNotEmpty, isTrue);

      buffered.flush();
      expect(sink.writes, ['hello world']);
      expect(buffered.isEmpty, isTrue);
    });

    test('flushes automatically when reaching maxBufferSize', () {
      final sink = _RecordingStringSink();
      final buffered = BufferedStringSink(sink, maxBufferSize: 10);

      buffered.write('12345');
      expect(sink.writes, isEmpty);

      buffered.write('67890');
      // Reached 10 chars, should automatically flush
      expect(sink.writes, ['1234567890']);
      expect(buffered.isEmpty, isTrue);
    });

    test('supports writeln, writeCharCode, and writeAll', () {
      final sink = _RecordingStringSink();
      final buffered = BufferedStringSink(sink, maxBufferSize: 100);

      buffered.writeCharCode(65); // 'A'
      buffered.writeAll(['B', 'C'], '-');
      buffered.writeln('D');

      expect(sink.writes, isEmpty);
      buffered.flush();

      expect(sink.writes, ['AB-CD\n']);
    });

    test('Sink<String> methods add and close work as write and flush', () {
      final sink = _RecordingStringSink();
      final buffered = BufferedStringSink(sink, maxBufferSize: 100);

      buffered.add('chunk');
      expect(sink.writes, isEmpty);

      buffered.close();
      expect(sink.writes, ['chunk']);
    });

    test('reuses existing BufferedStringSink without re-wrapping', () {
      final sink = _RecordingStringSink();
      final buffered1 = BufferedStringSink(sink);
      final buffered2 = BufferedStringSink(buffered1);

      expect(identical(buffered1, buffered2), isTrue);
    });

    test('writes directly into StringBuffer without intermediate buffering',
        () {
      final buffer = StringBuffer();
      final buffered = BufferedStringSink(buffer, maxBufferSize: 100);

      buffered.write('direct');
      expect(buffer.toString(), 'direct');
    });

    test(
        'BufferedStringSink.lazy defers sink creation until first non-empty flush',
        () {
      bool created = false;
      final recording = _RecordingStringSink();
      final buffered = BufferedStringSink.lazy(() {
        created = true;
        return recording;
      });

      expect(created, isFalse);

      buffered.flush(); // empty flush
      expect(created, isFalse);

      buffered.write('deferred');
      expect(created, isFalse);

      buffered.flush();
      expect(created, isTrue);
      expect(recording.writes, ['deferred']);
    });

    test('propagates flush when underlying sink is a BufferedStringSink', () {
      final recording = _RecordingStringSink();
      final outer = BufferedStringSink(recording, maxBufferSize: 1000);
      final inner = BufferedStringSink.lazy(() => outer, maxBufferSize: 1000);

      inner.write('nested data');
      expect(recording.writes, isEmpty);

      inner.flush();
      expect(recording.writes, ['nested data']);
    });
  });
}
