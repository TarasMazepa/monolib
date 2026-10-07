import 'dart:async';
import 'dart:convert';

import 'package:monolib_dart/json_encode_async.dart';
import 'package:monolib_openrouter/monolib_openrouter.dart';
import 'package:test/test.dart';

void main() {
  group('Utf8StreamStringSink', () {
    Future<String> collect(void Function(StringSink sink) write) async {
      final controller = StreamController<List<int>>();
      final result = controller.stream.transform(utf8.decoder).join();
      write(Utf8StreamStringSink(controller.sink));
      await controller.close();
      return result;
    }

    test('write encodes objects as utf8', () async {
      final result = await collect((sink) {
        sink.write('héllo ');
        sink.write(42);
        sink.write(null);
      });

      expect(result, equals('héllo 42null'));
    });

    test('writeAll without separator', () async {
      final result = await collect((sink) => sink.writeAll(['a', 1, 'ü']));

      expect(result, equals('a1ü'));
    });

    test('writeAll with separator', () async {
      final result =
          await collect((sink) => sink.writeAll(['a', 'b', 'c'], ', '));

      expect(result, equals('a, b, c'));
    });

    test('writeAll with empty iterable writes nothing', () async {
      final result = await collect((sink) => sink.writeAll([], ', '));

      expect(result, isEmpty);
    });

    test('writeCharCode encodes multi byte characters', () async {
      final result = await collect((sink) {
        sink.writeCharCode(0x41);
        sink.writeCharCode(0x20AC);
      });

      expect(result, equals('A€'));
    });

    test('writeln appends a new line', () async {
      final result = await collect((sink) {
        sink.writeln('line');
        sink.writeln();
      });

      expect(result, equals('line\n\n'));
    });

    test('works as a sink for jsonEncodeAsync output', () async {
      final payload = {
        'model': 'vendor/model',
        'messages': [
          {'role': 'user', 'content': 'héllo €'},
        ],
      };
      final controller = StreamController<List<int>>();
      final result = controller.stream.transform(utf8.decoder).join();

      await jsonEncodeAsync(
        object: payload,
        sink: Utf8StreamStringSink(controller.sink),
      );
      await controller.close();

      expect(jsonDecode(await result), equals(payload));
    });

    test('ignores writes after the sink is closed', () async {
      final controller = StreamController<List<int>>();
      final result = controller.stream.toList();
      final sink = Utf8StreamStringSink(controller.sink);
      await controller.close();

      expect(() => sink.write('late'), returnsNormally);
      expect(await result, isEmpty);
    });
  });
}
