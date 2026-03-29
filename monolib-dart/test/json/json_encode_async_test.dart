import 'dart:async';
import 'dart:convert';

import 'package:monolib_dart/json_encode_async.dart';
import 'package:test/test.dart';

class CustomWithToJson {
  dynamic toJson() => {'custom': true, 'nested': Future.value('value')};
}

class CustomWithoutToJson {
  final int id = 1;
}

class CustomWithAsyncToJson {
  dynamic toJson() => Future.value({'delayed': true});
}

Future<String> encodeToString(dynamic object) async {
  final buffer = StringBuffer();
  await jsonEncodeAsync(object, buffer);
  return buffer.toString();
}

void main() {
  group('jsonEncodeAsync', () {
    test('encodes primitive types', () async {
      expect(await encodeToString(null), 'null');
      expect(await encodeToString(42), '42');
      expect(await encodeToString(3.14), '3.14');
      expect(await encodeToString(true), 'true');
      expect(await encodeToString(false), 'false');
      expect(await encodeToString('hello'), '"hello"');
    });

    test('encodes Iterables and Streams as arrays', () async {
      expect(await encodeToString([1, 2, 3]), '[1,2,3]');
      expect(await encodeToString({'a', 'b'}), '["a","b"]');

      final stream = Stream.fromIterable([4, 5, 6]);
      expect(await encodeToString(stream), '[4,5,6]');
    });

    test('encodes Maps recursively', () async {
      final map = {
        'a': 1,
        'b': [2, 3],
        'c': {'d': 'hello'},
      };
      expect(await encodeToString(map), '{"a":1,"b":[2,3],"c":{"d":"hello"}}');
    });

    test('awaits Futures anywhere in the object', () async {
      final f = Future.value(42);
      expect(await encodeToString(f), '42');

      final map = {
        'futureValue': Future.value([1, 2]),
        Future.value('futureKey'): 'value',
      };
      expect(
        await encodeToString(map),
        '{"futureValue":[1,2],"futureKey":"value"}',
      );
    });

    test('throws standard jsonEncode error for invalid Map keys', () async {
      try {
        await encodeToString({1: 'value'});
        fail('Should have thrown');
      } catch (e) {
        expect(e, isA<JsonUnsupportedObjectError>());
        // Normal jsonEncode throws JsonUnsupportedObjectError or similar
        // We ensure we didn't just swallow it
      }
    });

    test('handles custom objects with toJson', () async {
      final obj = CustomWithToJson();
      expect(await encodeToString(obj), '{"custom":true,"nested":"value"}');
    });

    test('handles custom objects with toJson that returns Future', () async {
      final obj = CustomWithAsyncToJson();
      expect(await encodeToString(obj), '{"delayed":true}');
    });

    test(
      'throws standard jsonEncode error for custom objects without toJson',
      () async {
        final obj = CustomWithoutToJson();
        try {
          await encodeToString(obj);
          fail('Should have thrown');
        } catch (e) {
          expect(e, isA<JsonUnsupportedObjectError>());
        }
      },
    );

    test('encodes mixed nested async structures properly', () async {
      final complex = {
        'stream': Stream.fromIterable([
          1,
          Future.delayed(Duration(milliseconds: 10), () => 2),
          3,
        ]),
        'nestedMap': {'futureObj': Future.value(CustomWithToJson())},
      };

      final result = await encodeToString(complex);
      expect(
        result,
        '{"stream":[1,2,3],"nestedMap":{"futureObj":{"custom":true,"nested":"value"}}}',
      );
    });
  });
}
