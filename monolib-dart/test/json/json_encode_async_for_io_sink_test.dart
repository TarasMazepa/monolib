import 'package:monolib_dart/json_encode_async.dart';
import 'package:test/test.dart';

import '../io/mock_io_sink.dart';

void main() {
  group('jsonEncodeAsyncForIOSink', () {
    test('writes json to sink', () async {
      final data = {'hello': 'world'};
      final buffer = StringBuffer();
      final sink = MockIOSink(buffer);

      await jsonEncodeAsyncForIOSink(data: data, ioSink: sink);

      expect(buffer.toString(), '{"hello":"world"}');
    });

    test('writes json using ioSinkProvider lazily', () async {
      final data = {'hello': 'world'};
      final buffer = StringBuffer();
      final sink = MockIOSink(buffer);

      await jsonEncodeAsyncForIOSink(data: data, ioSinkProvider: () => sink);

      expect(buffer.toString(), '{"hello":"world"}');
    });
  });
}
