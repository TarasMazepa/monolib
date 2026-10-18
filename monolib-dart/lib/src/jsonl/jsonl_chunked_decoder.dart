import 'dart:convert';

import 'package:monolib_dart/src/common/chunked_only_converter.dart';
import 'package:monolib_dart/src/jsonl/jsonl_base_chunk_sink.dart';

/// A streaming converter that parses chunked JSON Lines (JSONL) string data
/// into decoded JSON objects.
///
/// [JsonlChunkedDecoder] extends [ChunkedOnlyConverter] and delegates stateful
/// line boundary scanning to [JsonlBaseChunkSink]. It transforms asynchronous
/// `Stream<String>` pipelines directly into streams of decoded JSON values and
/// also underpins synchronous converters such as `JsonlDecoder`.
///
/// Empty lines and lines that decode to `null` are skipped.
///
/// Example:
/// ```dart
/// final jsonStream = File('data.jsonl')
///     .openRead()
///     .transform(utf8.decoder)
///     .transform(const JsonlChunkedDecoder());
///
/// await for (final jsonObject in jsonStream) {
///   print(jsonObject['id']);
/// }
/// ```
class JsonlChunkedDecoder extends ChunkedOnlyConverter<String, dynamic> {
  /// The underlying [Codec] used to decode individual JSON lines.
  ///
  /// Defaults to [JsonCodec], or can be customized to supply a custom decoding
  /// strategy.
  final Codec<Object?, String> jsonCodec;

  /// Creates a [JsonlChunkedDecoder].
  ///
  /// Uses [jsonCodec] (defaulting to `const JsonCodec()`) to decode each line.
  const JsonlChunkedDecoder({this.jsonCodec = const JsonCodec()});

  /// Starts a chunked conversion that parses incoming JSONL string chunks and
  /// emits decoded JSON objects to [sink].
  @override
  Sink<String> startChunkedConversion(Sink<dynamic> sink) {
    return _JsonlChunkedDecoderSink(sink, jsonCodec);
  }
}

/// Internal [JsonlBaseChunkSink] implementation for [JsonlChunkedDecoder].
class _JsonlChunkedDecoderSink extends JsonlBaseChunkSink<dynamic> {
  /// The underlying codec used to decode individual lines.
  final Codec<Object?, String> jsonCodec;

  /// Creates a sink that decodes lines with [jsonCodec] and forwards non-null
  /// results to [outSink].
  _JsonlChunkedDecoderSink(super.outSink, this.jsonCodec);

  /// Decodes [line] using [jsonCodec] and emits the result to [outSink] if
  /// non-null.
  @override
  void processLine(String line) {
    final json = jsonCodec.decode(line);
    if (json != null) {
      outSink.add(json);
    }
  }
}
