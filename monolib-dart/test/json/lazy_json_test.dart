import 'dart:convert';
import 'package:monolib_dart/json_encode_async.dart';
import 'package:monolib_dart/fluent_json.dart';
import 'package:test/test.dart';

void main() {
  group('LazyJson', () {
    test('works with standard jsonEncode', () {
      bool called = false;
      final lazy = LazyJson(() {
        called = true;
        return {'hello': 'world'};
      });

      expect(called, isFalse);

      final result = jsonEncode(lazy);

      expect(called, isTrue);
      expect(result, '{"hello":"world"}');
    });

    test('works with standard jsonEncode returning a string', () {
      bool called = false;
      final lazy = LazyJson(() {
        called = true;
        return 'a string';
      });

      expect(called, isFalse);

      final result = jsonEncode(lazy);

      expect(called, isTrue);
      expect(result, '"a string"');
    });

    test('works with jsonEncodeAsync', () async {
      bool called = false;
      final lazy = LazyJson(() {
        called = true;
        return {'key': 'value'};
      });

      expect(called, isFalse);

      final buffer = StringBuffer();
      await jsonEncodeAsync(lazy, buffer);

      expect(called, isTrue);
      expect(buffer.toString(), '{"key":"value"}');
    });

    test('works with jsonEncodeAsync and Future', () async {
      bool called = false;
      final lazy = LazyJson(() {
        called = true;
        return Future.value({'key': 'async value'});
      });

      expect(called, isFalse);

      final buffer = StringBuffer();
      await jsonEncodeAsync(lazy, buffer);

      expect(called, isTrue);
      expect(buffer.toString(), '{"key":"async value"}');
    });
  });
}
