import 'package:monolib_dart/jsonl.dart';
import 'package:test/test.dart';

import '../io/mock_io_sink.dart';

void main() {
  group('jsonlEncodeAsyncForIOSink', () {
    test('writes jsonl to sink', () async {
      final data = [
        {'hello': 'world'},
        {'goodbye': 'world'},
      ];
      final buffer = StringBuffer();
      final sink = MockIOSink(buffer);

      await jsonlEncodeAsyncForIOSink(items: data, ioSink: sink);

      expect(buffer.toString(), '{"hello":"world"}\n{"goodbye":"world"}\n');
    });

    test('writes jsonl using ioSinkProvider lazily', () async {
      final data = [
        {'hello': 'world'},
        {'goodbye': 'world'},
      ];
      final buffer = StringBuffer();
      final sink = MockIOSink(buffer);

      await jsonlEncodeAsyncForIOSink(items: data, ioSinkProvider: () => sink);

      expect(buffer.toString(), '{"hello":"world"}\n{"goodbye":"world"}\n');
    });
  });
}
