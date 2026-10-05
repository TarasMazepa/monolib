import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:monolib_openrouter/src/api/ai_model.dart';
import 'package:monolib_openrouter/src/api/ai_vendor_client.dart';
import 'package:monolib_openrouter/src/http/drop_leading_whitespace.dart';
import 'package:monolib_openrouter/src/http/utf8_stream_string_sink.dart';
import 'package:monolib_dart/fluent_json.dart';
import 'package:monolib_dart/json_encode_async.dart';
import 'package:monolib_dart/stream.dart';
import 'package:monolib_openrouter/src/api/on_fluent_json.dart';

class OpenRouterClient extends AiVendorClient {
  OpenRouterClient({
    required String apiKey,
    http.Client? client,
  })  : _apiKey = apiKey,
        _client = client ?? http.Client();

  final String _apiKey;
  final http.Client _client;

  @override
  final vendorsBlocklist = const <String>{};

  final _apiUrlString = 'https://openrouter.ai/api/v1/chat/completions';
  late final Uri _apiUrl = Uri.parse(_apiUrlString);
  late final _chunkedParser =
      const DropLeadingWhitespace().fuse(utf8.decoder).fuse(json.decoder);

  late final _headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $_apiKey',
  };

  @override
  Stream<String> ask({
    required Object userPrompt,
    required Object? systemPrompt,
    required AiModel model,
    required String useCase,
  }) {
    final payload = {
      'model': '${model.vendor}/${model.name}',
      'messages': [
        if (systemPrompt != null) {'role': 'system', 'content': systemPrompt},
        {'role': 'user', 'content': userPrompt},
      ],
      'plugins': const [
        {'id': 'web'},
      ],
      'usage': const {'include': true},
    };

    final request = http.StreamedRequest('POST', _apiUrl)
      ..headers.addAll(_headers);

    Future(() async {
      final sink = request.sink;
      try {
        await jsonEncodeAsync(
          object: payload,
          sink: Utf8StreamStringSink(sink),
        );
      } catch (error, stackTrace) {
        sink.tryAddError(
          error,
          stackTrace: stackTrace,
          ignoreError: true,
        );
      } finally {
        sink.close();
      }
    });

    return _client.send(request).asStream().asyncExpand((response) {
      if (response.statusCode != 200) {
        throw Exception(
          'OpenRouter API error: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
      return response.stream.transform(_chunkedParser).map((rawJson) {
        final json = FluentJson.root(rawJson);
        return json
            .assertNoTopLevelError()['choices']
            .unboxIterable()
            .first['message']
            .unboxed<String>('content');
      });
    });
  }
}
