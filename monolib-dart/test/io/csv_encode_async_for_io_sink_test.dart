import 'package:monolib_dart/io.dart';
import 'package:test/test.dart';

import 'mock_io_sink.dart';

void main() {
  group('csvEncodeAsyncForIOSink', () {
    test('returns a function that writes csv to sink', () async {
      final data = [
        ['hello', 'world'],
        ['foo', 'bar']
      ];
      final buffer = StringBuffer();
      final sink = MockIOSink(buffer);

      final func = csvEncodeAsyncForIOSink(data);
      await func(sink);

      expect(buffer.toString(), 'hello,world\r\nfoo,bar\r\n');
    });
  });
}
