import 'package:monolib_dart/json_encode_async.dart';
import 'package:test/test.dart';

import 'mock_io_sink.dart';

void main() {
  group('jsonEncodeAsyncForIOSink', () {
    test('returns a function that writes json to sink', () async {
      final data = {'hello': 'world'};
      final buffer = StringBuffer();
      final sink = MockIOSink(buffer);

      final func = jsonEncodeAsyncForIOSink(data);
      await func(sink);

      expect(buffer.toString(), '{"hello":"world"}');
    });
  });
}
