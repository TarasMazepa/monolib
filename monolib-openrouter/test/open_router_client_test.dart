import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:monolib_openrouter/monolib_openrouter.dart';
import 'package:test/test.dart';

void main() {
  group('OpenRouterClient', () {
    String completion(String content, {num? cost}) => jsonEncode({
          'choices': [
            {
              'message': {'role': 'assistant', 'content': content},
            },
          ],
          if (cost != null) 'usage': {'cost': cost},
        });

    http.StreamedResponse respond(List<String> chunks, {int status = 200}) =>
        http.StreamedResponse(
          Stream<List<int>>.fromIterable(chunks.map(utf8.encode)),
          status,
        );

    OpenRouterClient createClient(MockClientStreamHandler handler) =>
        OpenRouterClient(
            apiKey: 'test-key', httpClient: MockClient.streaming(handler));

    test('sends request body with model and messages', () async {
      late Map<String, dynamic> body;
      final client = createClient((request, bodyStream) async {
        body = jsonDecode(await bodyStream.bytesToString());
        return respond([completion('ok')]);
      });

      await client
          .ask(
            model: 'anthropic/claude-sonnet-5',
            userPrompt: 'héllo',
            systemPrompt: 'be brief',
          )
          .toList();

      expect(
        body,
        equals({
          'model': 'anthropic/claude-sonnet-5',
          'messages': [
            {'role': 'system', 'content': 'be brief'},
            {'role': 'user', 'content': 'héllo'},
          ],
          'usage': {'include': true},
        }),
      );
    });

    test('omits system message, plugins and usage when not requested',
        () async {
      late Map<String, dynamic> body;
      final client = createClient((request, bodyStream) async {
        body = jsonDecode(await bodyStream.bytesToString());
        return respond([completion('ok')]);
      });

      await client
          .ask(model: 'openai/gpt', userPrompt: 'hi', includeUsage: false)
          .toList();

      expect(
        body,
        equals({
          'model': 'openai/gpt',
          'messages': [
            {'role': 'user', 'content': 'hi'},
          ],
        }),
      );
    });

    test('sends plugins', () async {
      late Map<String, dynamic> body;
      final client = createClient((request, bodyStream) async {
        body = jsonDecode(await bodyStream.bytesToString());
        return respond([completion('ok')]);
      });

      await client.ask(
        model: 'openai/gpt',
        userPrompt: 'hi',
        plugins: const [
          {'id': 'web'},
        ],
      ).toList();

      expect(
        body['plugins'],
        equals([
          {'id': 'web'},
        ]),
      );
    });

    test('sends POST with auth and content type headers to api url', () async {
      late http.BaseRequest sent;
      final client = createClient((request, bodyStream) async {
        sent = request;
        await bodyStream.drain<void>();
        return respond([completion('ok')]);
      });

      await client.ask(model: 'openai/gpt', userPrompt: 'hi').toList();

      expect(sent.method, equals('POST'));
      expect(sent.url, equals(OpenRouterClient.defaultApiUrl));
      expect(sent.headers['Authorization'], equals('Bearer test-key'));
      expect(sent.headers['Content-Type'], startsWith('application/json'));
    });

    test('uses provided api url', () async {
      late Uri url;
      final client = OpenRouterClient(
        apiKey: 'test-key',
        apiUrl: Uri.parse('https://example.com/v1/chat/completions'),
        httpClient: MockClient.streaming((request, bodyStream) async {
          url = request.url;
          await bodyStream.drain<void>();
          return respond([completion('ok')]);
        }),
      );

      await client.ask(model: 'openai/gpt', userPrompt: 'hi').toList();

      expect(url, equals(Uri.parse('https://example.com/v1/chat/completions')));
    });

    test('emits content of the first choice', () async {
      final client = createClient((request, bodyStream) async {
        await bodyStream.drain<void>();
        return respond([completion('A rose')]);
      });

      final result =
          await client.ask(model: 'openai/gpt', userPrompt: 'hi').toList();

      expect(result, equals(['A rose']));
    });

    test('parses response split across chunks', () async {
      final response = completion('A rose');
      final client = createClient((request, bodyStream) async {
        await bodyStream.drain<void>();
        return respond([
          response.substring(0, 10),
          response.substring(10, 25),
          response.substring(25),
        ]);
      });

      final result =
          await client.ask(model: 'openai/gpt', userPrompt: 'hi').toList();

      expect(result, equals(['A rose']));
    });

    test('skips leading whitespace sent before the response', () async {
      final client = createClient((request, bodyStream) async {
        await bodyStream.drain<void>();
        return respond(
            ['\n         \n', '\n         \n', completion('A rose')]);
      });

      final result =
          await client.ask(model: 'openai/gpt', userPrompt: 'hi').toList();

      expect(result, equals(['A rose']));
    });

    test('reports cost from usage', () async {
      final costs = <num>[];
      final client = createClient((request, bodyStream) async {
        await bodyStream.drain<void>();
        return respond([completion('ok', cost: 0.0123)]);
      });

      await client
          .ask(model: 'openai/gpt', userPrompt: 'hi', onCost: costs.add)
          .toList();

      expect(costs, equals([0.0123]));
    });

    test('does not report cost when usage is missing', () async {
      final costs = <num>[];
      final client = createClient((request, bodyStream) async {
        await bodyStream.drain<void>();
        return respond([completion('ok')]);
      });

      await client
          .ask(model: 'openai/gpt', userPrompt: 'hi', onCost: costs.add)
          .toList();

      expect(costs, isEmpty);
    });

    test('emits error for top level error response', () async {
      final client = createClient((request, bodyStream) async {
        await bodyStream.drain<void>();
        return respond([
          jsonEncode({
            'error': {'code': 429, 'message': 'Rate limited'},
          }),
        ], status: 429);
      });

      await expectLater(
        client.ask(model: 'openai/gpt', userPrompt: 'hi'),
        emitsError(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Rate limited'),
          ),
        ),
      );
    });

    test(
        'closes empty and calls onRequestTimeout when response does not arrive',
        () async {
      bool timedOut = false;
      final client = createClient((request, bodyStream) async {
        await bodyStream.drain<void>();
        return Completer<http.StreamedResponse>().future;
      });

      final result = await client
          .ask(
            model: 'openai/gpt',
            userPrompt: 'hi',
            requestTimeout: const Duration(milliseconds: 10),
            onRequestTimeout: () => timedOut = true,
          )
          .toList();

      expect(result, isEmpty);
      expect(timedOut, isTrue);
    });

    test(
      'calls onResponseTimeout and emits FormatException when body stalls',
      () async {
        int? timedOutStatusCode;
        final body = StreamController<List<int>>();
        addTearDown(body.close);
        final client = createClient((request, bodyStream) async {
          await bodyStream.drain<void>();
          body.add(utf8.encode('\n   \n{"choices": ['));
          return http.StreamedResponse(body.stream, 200);
        });

        await expectLater(
          client.ask(
            model: 'openai/gpt',
            userPrompt: 'hi',
            responseTimeout: const Duration(milliseconds: 10),
            onResponseTimeout: (statusCode) => timedOutStatusCode = statusCode,
          ),
          emitsError(isA<FormatException>()),
        );
        expect(timedOutStatusCode, equals(200));
      },
    );

    test('does not call timeout callbacks when response is in time', () async {
      bool timedOut = false;
      final client = createClient((request, bodyStream) async {
        await bodyStream.drain<void>();
        return respond([completion('ok')]);
      });

      final result = await client
          .ask(
            model: 'openai/gpt',
            userPrompt: 'hi',
            requestTimeout: const Duration(seconds: 5),
            onRequestTimeout: () => timedOut = true,
            responseTimeout: const Duration(seconds: 5),
            onResponseTimeout: (_) => timedOut = true,
          )
          .toList();

      expect(result, equals(['ok']));
      expect(timedOut, isFalse);
    });
  });
}
