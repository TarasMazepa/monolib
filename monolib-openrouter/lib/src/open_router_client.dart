import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:monolib_dart/fluent_json.dart';
import 'package:monolib_dart/json_encode_async.dart';
import 'package:monolib_dart/stream.dart';
import 'package:monolib_openrouter/src/drop_leading_whitespace_converter.dart';
import 'package:monolib_openrouter/src/on_fluent_json.dart';
import 'package:monolib_openrouter/src/on_future.dart';
import 'package:monolib_openrouter/src/on_stream.dart';
import 'package:monolib_openrouter/src/utf8_stream_string_sink.dart';

/// A client for the OpenRouter chat completions API.
///
/// The request body is streamed as it is encoded and the response is parsed
/// as it arrives, skipping the leading whitespace OpenRouter sends to keep
/// the connection alive.
class OpenRouterClient {
  /// Default OpenRouter chat completions endpoint.
  static final defaultApiUrl = Uri.parse(
    'https://openrouter.ai/api/v1/chat/completions',
  );

  final String _apiKey;
  final http.Client _httpClient;

  /// The endpoint requests are sent to.
  final Uri apiUrl;

  /// Creates an [OpenRouterClient] authenticated with [apiKey] that sends
  /// requests with [httpClient].
  ///
  /// [httpClient] is owned by the caller, who is responsible for closing it.
  OpenRouterClient({
    required String apiKey,
    required http.Client httpClient,
    Uri? apiUrl,
  })  : _apiKey = apiKey,
        _httpClient = httpClient,
        apiUrl = apiUrl ?? defaultApiUrl;

  /// Sends [userPrompt] and optional [systemPrompt] to [model] and returns a
  /// stream with the content of the first choice of the response.
  ///
  /// [model] is the OpenRouter model id, e.g. `anthropic/claude-sonnet-5`.
  /// [plugins] are passed as is, e.g. `[{'id': 'web'}]`.
  ///
  /// When [includeUsage] is `true`, the cost reported by OpenRouter is passed
  /// to [onCost].
  ///
  /// When the response doesn't arrive within [requestTimeout], the returned
  /// stream closes without emitting and [onRequestTimeout] is called.
  ///
  /// When the response body doesn't progress within [responseTimeout],
  /// [onResponseTimeout] is called with the response status code and the body
  /// is closed, so the returned stream emits a [FormatException] for the
  /// incomplete json.
  ///
  /// No timeout is applied when a time limit is not provided.
  ///
  /// [wrapRequestSink] and [wrapResponseStream] allow observing the raw
  /// request and response bytes, e.g. for logging.
  ///
  /// [onError] is called when adding to an internal sink fails. Such errors
  /// are ignored, so without [onError] they are silently dropped.
  ///
  /// The returned stream emits an error when the response contains a top
  /// level `error` element.
  Stream<String> ask({
    required String model,
    required Object userPrompt,
    Object? systemPrompt,
    List<Object> plugins = const [],
    bool includeUsage = true,
    void Function(num cost)? onCost,
    Duration? requestTimeout,
    void Function()? onRequestTimeout,
    Duration? responseTimeout,
    void Function(int statusCode)? onResponseTimeout,
    EventSink<List<int>> Function(EventSink<List<int>> sink)? wrapRequestSink,
    Stream<List<int>> Function(Stream<List<int>> stream)? wrapResponseStream,
    void Function(Object error, StackTrace stackTrace)? onError,
  }) {
    final payload = {
      'model': model,
      'messages': [
        if (systemPrompt != null) {'role': 'system', 'content': systemPrompt},
        {'role': 'user', 'content': userPrompt},
      ],
      if (plugins.isNotEmpty) 'plugins': plugins,
      if (includeUsage) 'usage': const {'include': true},
    };

    final request = http.StreamedRequest('POST', apiUrl)
      ..headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      });

    Future(() async {
      final sink = wrapRequestSink?.call(request.sink) ?? request.sink;
      try {
        await jsonEncodeAsync(
          object: payload,
          sink: Utf8StreamStringSink(sink, onError: onError),
        );
      } catch (error, stackTrace) {
        sink.tryAddError(
          error,
          stackTrace: stackTrace,
          ignoreError: true,
          onError: onError,
        );
      } finally {
        sink.close();
      }
    });

    final chunkedParser = DropLeadingWhitespaceConverter(
      onError: onError,
    ).fuse(utf8.decoder).fuse(json.decoder);

    final responseFuture = _httpClient.send(request);
    final responses = requestTimeout == null
        ? Stream.fromFuture(responseFuture)
        : responseFuture.timeoutAsStream(
            timeLimit: requestTimeout,
            onTimeout: onRequestTimeout,
          );

    return responses.asyncExpand((response) {
      final body = wrapResponseStream?.call(response.stream) ?? response.stream;
      final timedBody = responseTimeout == null
          ? body
          : body.timeoutAndClose(
              timeLimit: responseTimeout,
              onTimeout: () => onResponseTimeout?.call(response.statusCode),
            );
      return timedBody.transform(chunkedParser).map((rawJson) {
        final json = FluentJson.root(rawJson);
        if (json.elementAt('usage')?.unboxedElementAt<num>('cost')
            case final cost?) {
          onCost?.call(cost);
        }
        return json
            .assertNoTopLevelError()['choices']
            .unboxIterable()
            .first['message']
            .unboxed<String>('content');
      });
    });
  }
}
