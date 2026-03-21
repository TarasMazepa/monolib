import 'dart:convert';
import 'dart:async';
import 'package:test/test.dart';

import 'package:monolib_dart/json_encode_async.dart';

class CustomWithToJson {
  dynamic toJson() => {'custom': true, 'nested': Future.value('value')};
}

class CustomWithoutToJson {
  final int id = 1;
}

class CustomWithAsyncToJson {
  dynamic toJson() => Future.value({'delayed': true});
}

void main() {
  group('jsonEncodeAsync', () {
    test('encodes primitive types', () async {
      expect(await jsonEncodeAsync(null).join(), 'null');
      expect(await jsonEncodeAsync(42).join(), '42');
      expect(await jsonEncodeAsync(3.14).join(), '3.14');
      expect(await jsonEncodeAsync(true).join(), 'true');
      expect(await jsonEncodeAsync(false).join(), 'false');
      expect(await jsonEncodeAsync('hello').join(), '"hello"');
    });

    test('encodes Iterables and Streams as arrays', () async {
      expect(await jsonEncodeAsync([1, 2, 3]).join(), '[1,2,3]');
      expect(await jsonEncodeAsync({'a', 'b'}).join(), '["a","b"]');

      final stream = Stream.fromIterable([4, 5, 6]);
      expect(await jsonEncodeAsync(stream).join(), '[4,5,6]');
    });

    test('encodes Maps recursively', () async {
      final map = {
        'a': 1,
        'b': [2, 3],
        'c': {'d': 'hello'}
      };
      expect(await jsonEncodeAsync(map).join(), '{"a":1,"b":[2,3],"c":{"d":"hello"}}');
    });

    test('awaits Futures anywhere in the object', () async {
      final f = Future.value(42);
      expect(await jsonEncodeAsync(f).join(), '42');

      final map = {
        'futureValue': Future.value([1, 2]),
        Future.value('futureKey'): 'value'
      };
      expect(await jsonEncodeAsync(map).join(), '{"futureValue":[1,2],"futureKey":"value"}');
    });

    test('throws standard jsonEncode error for invalid Map keys', () async {
      try {
        await jsonEncodeAsync({1: 'value'}).join();
        fail('Should have thrown');
      } catch (e) {
        expect(e, isA<JsonUnsupportedObjectError>());
        // Normal jsonEncode throws JsonUnsupportedObjectError or similar
        // We ensure we didn't just swallow it
      }
    });

    test('handles custom objects with toJson', () async {
      final obj = CustomWithToJson();
      expect(await jsonEncodeAsync(obj).join(), '{"custom":true,"nested":"value"}');
    });

    test('handles custom objects with toJson that returns Future', () async {
      final obj = CustomWithAsyncToJson();
      expect(await jsonEncodeAsync(obj).join(), '{"delayed":true}');
    });

    test('throws standard jsonEncode error for custom objects without toJson', () async {
      final obj = CustomWithoutToJson();
      try {
        await jsonEncodeAsync(obj).join();
        fail('Should have thrown');
      } catch (e) {
        expect(e, isA<JsonUnsupportedObjectError>());
      }
    });

    test('encodes mixed nested async structures properly', () async {
      final complex = {
        'stream': Stream.fromIterable([
          1,
          Future.delayed(Duration(milliseconds: 10), () => 2),
          3
        ]),
        'nestedMap': {
          'futureObj': Future.value(CustomWithToJson())
        }
      };

      final result = await jsonEncodeAsync(complex).join();
      expect(result, '{"stream":[1,2,3],"nestedMap":{"futureObj":{"custom":true,"nested":"value"}}}');
    });
  });
}
