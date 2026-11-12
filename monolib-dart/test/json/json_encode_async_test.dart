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

class _CustomDelayedToJson {
  final Future<dynamic> future;
  _CustomDelayedToJson(this.future);
  dynamic toJson() => future;
}

class _CustomStringSink implements StringSink {
  final List<String> writes;
  _CustomStringSink(this.writes);

  @override
  void write(Object? object) {
    writes.add('$object');
  }

  @override
  void writeAll(Iterable<dynamic> objects, [String separator = '']) {
    writes.add(objects.join(separator));
  }

  @override
  void writeCharCode(int charCode) {
    writes.add(String.fromCharCode(charCode));
  }

  @override
  void writeln([Object? object = '']) {
    writes.add('$object\n');
  }
}

Future<String> encodeToString(dynamic object) async {
  final buffer = StringBuffer();
  await jsonEncodeAsync(object: object, sink: buffer);
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

    test(
      'flushes prior buffered writes before awaiting nested future',
      () async {
        final completer = Completer<int>();
        final writes = <String>[];
        final sink = _CustomStringSink(writes);
        final complex = {
          'syncKey': 'syncVal',
          'asyncKey': completer.future,
        };

        final future = jsonEncodeAsync(object: complex, sink: sink);
        await Future<void>.delayed(Duration.zero);

        expect(writes.join(), '{"syncKey":"syncVal","asyncKey":');

        completer.complete(42);
        await future;

        expect(writes.join(), '{"syncKey":"syncVal","asyncKey":42}');
      },
    );

    test(
      'flushes prior buffered writes before awaiting next stream item',
      () async {
        final controller = StreamController<int>();
        final writes = <String>[];
        final sink = _CustomStringSink(writes);

        final future = jsonEncodeAsync(object: controller.stream, sink: sink);

        controller.add(1);
        await Future<void>.delayed(Duration.zero);
        expect(writes.join(), '[1');

        controller.add(2);
        await Future<void>.delayed(Duration.zero);
        expect(writes.join(), '[1,2');

        controller.close();
        await future;
        expect(writes.join(), '[1,2]');
      },
    );

    test(
      'flushes prior buffered writes before awaiting future map key',
      () async {
        final completer = Completer<String>();
        final writes = <String>[];
        final sink = _CustomStringSink(writes);
        final complex = {
          'syncKey': 'syncVal',
          completer.future: 100,
        };

        final future = jsonEncodeAsync(object: complex, sink: sink);
        await Future<void>.delayed(Duration.zero);

        expect(writes.join(), '{"syncKey":"syncVal",');

        completer.complete('asyncKey');
        await future;

        expect(writes.join(), '{"syncKey":"syncVal","asyncKey":100}');
      },
    );

    test(
      'flushes prior buffered writes before awaiting async toJson',
      () async {
        final completer = Completer<Map<String, dynamic>>();
        final writes = <String>[];
        final sink = _CustomStringSink(writes);

        final complex = {
          'syncKey': 'syncVal',
          'lazy': _CustomDelayedToJson(completer.future),
        };

        final future = jsonEncodeAsync(object: complex, sink: sink);
        await Future<void>.delayed(Duration.zero);

        expect(writes.join(), '{"syncKey":"syncVal","lazy":');

        completer.complete({'inner': 'value'});
        await future;

        expect(
          writes.join(),
          '{"syncKey":"syncVal","lazy":{"inner":"value"}}',
        );
      },
    );

    test(
      'flushes prior buffered writes before awaiting future iterable elements',
      () async {
        final completer1 = Completer<int>();
        final completer2 = Completer<int>();
        final writes = <String>[];
        final sink = _CustomStringSink(writes);

        final list = [1, completer1.future, completer2.future, 4];
        final future = jsonEncodeAsync(object: list, sink: sink);
        await Future<void>.delayed(Duration.zero);

        expect(writes.join(), '[1,');

        completer1.complete(2);
        await Future<void>.delayed(Duration.zero);

        expect(writes.join(), '[1,2,');

        completer2.complete(3);
        await future;

        expect(writes.join(), '[1,2,3,4]');
      },
    );

    test(
      'flushes prior buffered writes before awaiting future map values',
      () async {
        final completer1 = Completer<int>();
        final completer2 = Completer<int>();
        final writes = <String>[];
        final sink = _CustomStringSink(writes);

        final map = {
          'a': 1,
          'b': completer1.future,
          'c': completer2.future,
          'd': 4,
        };
        final future = jsonEncodeAsync(object: map, sink: sink);
        await Future<void>.delayed(Duration.zero);

        expect(writes.join(), '{"a":1,"b":');

        completer1.complete(2);
        await Future<void>.delayed(Duration.zero);

        expect(writes.join(), '{"a":1,"b":2,"c":');

        completer2.complete(3);
        await future;

        expect(writes.join(), '{"a":1,"b":2,"c":3,"d":4}');
      },
    );
  });
}
