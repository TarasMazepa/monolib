import 'dart:async';
import 'package:monolib_dart/json_encode_async.dart';
import 'package:test/test.dart';

class _CustomWritable implements AsyncJsonWritable {
  final String value;
  _CustomWritable(this.value);

  @override
  Future<void> writeJsonAsync(
      StringSink sink, JsonEncoderCallback encode) async {
    sink.write('{"custom":');
    await encode(value);
    sink.write('}');
  }
}

void main() {
  group('AsyncJsonWritable and StreamingJsonString', () {
    test('AsyncJsonWritable correctly delegates writing', () async {
      final buffer = StringBuffer();
      final obj = {'key': _CustomWritable('testValue')};

      await jsonEncodeAsync(
        object: obj,
        sink: buffer,
      );

      expect(buffer.toString(), '{"key":{"custom":"testValue"}}');
    });

    test('StreamingJsonString streams and escapes strings correctly', () async {
      final buffer = StringBuffer();

      final streamController = StreamController<String>();
      final obj = {
        'streamedString': StreamingJsonString(streamController.stream)
      };

      final encodeFuture = jsonEncodeAsync(
        object: obj,
        sink: buffer,
      );

      streamController.add('chunk 1, ');
      streamController.add('chunk with "quotes"');
      streamController.add('\nand newlines');
      streamController.close();

      await encodeFuture;

      // Expected result: {"streamedString":"chunk 1, chunk with \"quotes\"\nand newlines"}
      expect(buffer.toString(),
          '{"streamedString":"chunk 1, chunk with \\"quotes\\"\\nand newlines"}');
    });
  });
}
