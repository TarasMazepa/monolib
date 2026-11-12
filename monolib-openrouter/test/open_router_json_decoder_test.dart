import 'dart:convert';

import 'package:monolib_dart/fluent_json.dart';
import 'package:monolib_openrouter/monolib_openrouter.dart';
import 'package:test/test.dart';

void main() {
  group('openRouterJsonDecoder', () {
    test('decodes byte stream with leading whitespace', () async {
      final stream = Stream<List<int>>.fromIterable([
        utf8.encode('  \r\n\t {"key": "value"}'),
      ]);

      final result = await stream.transform(openRouterJsonDecoder).toList();

      expect(
          result,
          equals([
            {'key': 'value'}
          ]));
    });

    test('decodes byte stream without leading whitespace', () async {
      final stream = Stream<List<int>>.fromIterable([
        utf8.encode('{"key": "value"}'),
      ]);

      final result = await stream.transform(openRouterJsonDecoder).toList();

      expect(
          result,
          equals([
            {'key': 'value'}
          ]));
    });

    test('preserves whitespace inside JSON content', () async {
      final stream = Stream<List<int>>.fromIterable([
        utf8.encode(' \n {"text": "hello   world\\n\\nfoo", "num": 42}'),
      ]);

      final result = await stream.transform(openRouterJsonDecoder).toList();

      expect(
        result,
        equals([
          {
            'text': 'hello   world\n\nfoo',
            'num': 42,
          },
        ]),
      );
    });

    test('handles leading whitespace spread across multiple chunks', () async {
      final stream = Stream<List<int>>.fromIterable([
        utf8.encode('  \r\n'),
        utf8.encode('\t  '),
        utf8.encode('{"choices": [{"delta": {"content": "hi"}}]}'),
      ]);

      final result = await stream.transform(openRouterJsonDecoder).toList();

      expect(
        result,
        equals([
          {
            'choices': [
              {
                'delta': {'content': 'hi'},
              },
            ],
          },
        ]),
      );
    });

    test('handles JSON payload split across multiple chunks', () async {
      final stream = Stream<List<int>>.fromIterable([
        utf8.encode('\r\n {"id": "chat-'),
        utf8.encode('123", "created": '),
        utf8.encode('1700000000}'),
      ]);

      final result = await stream.transform(openRouterJsonDecoder).toList();

      expect(
        result,
        equals([
          {
            'id': 'chat-123',
            'created': 1700000000,
          },
        ]),
      );
    });

    test('can transform multiple streams independently', () async {
      final stream1 = Stream<List<int>>.fromIterable([
        utf8.encode('  {"first": 1}'),
      ]);
      final stream2 = Stream<List<int>>.fromIterable([
        utf8.encode('\n\n\t{"second": 2}'),
      ]);

      final result1 = await stream1.transform(openRouterJsonDecoder).toList();
      final result2 = await stream2.transform(openRouterJsonDecoder).toList();

      expect(
          result1,
          equals([
            {'first': 1}
          ]));
      expect(
          result2,
          equals([
            {'second': 2}
          ]));
    });

    test('throws FormatException on malformed JSON payload', () async {
      final stream = Stream<List<int>>.fromIterable([
        utf8.encode('\r\n {not valid json}'),
      ]);

      expect(
        stream.transform(openRouterJsonDecoder).toList(),
        throwsA(isA<FormatException>()),
      );
    });

    test('fuses with JsonMappedConverter to extract fields directly', () async {
      final stream = Stream<List<int>>.fromIterable([
        utf8.encode(
            '  \r\n {"choices":[{"message":{"content":"hello from openrouter"}}]}'),
      ]);

      final pipeline = openRouterJsonDecoder.fuse(
        JsonMappedConverter<String>(
          (json) => json
              .assertNoTopLevelError()['choices']
              .unboxIterable()
              .first['message']
              .unboxed<String>('content'),
        ),
      );

      final result = await stream.transform(pipeline).toList();

      expect(result, equals(['hello from openrouter']));
    });
  });
}
