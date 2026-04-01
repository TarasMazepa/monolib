import 'package:monolib_dart/jsonl.dart';
import 'package:test/test.dart';

import 'mock_io_sink.dart';

void main() {
  group('jsonlEncodeAsyncForIOSink', () {
    test('returns a function that writes jsonl to sink', () async {
      final data = [
        {'hello': 'world'},
        {'foo': 'bar'}
      ];
      final buffer = StringBuffer();
      final sink = MockIOSink(buffer);

      final func = jsonlEncodeAsyncForIOSink(data);
      await func(sink);

      expect(buffer.toString(), '{"hello":"world"}\n{"foo":"bar"}\n');
    });
  });
}
