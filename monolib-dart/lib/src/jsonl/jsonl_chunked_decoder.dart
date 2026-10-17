import 'dart:convert';

import 'package:monolib_dart/src/common/chunked_only_converter.dart';
import 'package:monolib_dart/src/jsonl/jsonl_base_chunk_sink.dart';

/// Serves as the asynchronous, stream-based foundation for JSON Lines (JSONL) ingestion.
///
/// Architecturally, [JsonlChunkedDecoder] extends [ChunkedOnlyConverter]. It
/// bypasses synchronous blocking and delegates stateful newline boundary
/// scanning to [JsonlBaseChunkSink]. This allows it to act as the core parsing
/// engine for both native stream pipelines and synchronous adapters like
/// [JsonlDecoder], maintaining unified parsing logic and adhering to DRY principles.
///
/// It strictly drops any empty lines or lines that evaluate to a `null` JSON
/// structure.
///
/// **Real-world example:**
/// ```dart
/// final Stream<String> byteStream = File('massive_data.jsonl')
///     .openRead()
///     .transform(utf8.decoder);
///
/// // Transform the stream of raw string chunks directly into a stream
/// // of parsed JSON objects.
/// final Stream<dynamic> jsonStream = byteStream
///     .transform(const JsonlChunkedDecoder());
///
/// await for (final jsonObject in jsonStream) {
///   print(jsonObject['id']);
/// }
/// ```
class JsonlChunkedDecoder extends ChunkedOnlyConverter<String, dynamic> {
  /// The underlying [Codec] used to parse the isolated string lines.
  ///
  /// This typically defaults to `dart:convert`'s [JsonCodec], but can be
  /// overridden to inject customized decoding strategies.
  final Codec<Object?, String> jsonCodec;

  /// Creates a new [JsonlChunkedDecoder].
  ///
  /// The [jsonCodec] defaults to a standard [JsonCodec] to evaluate standard
  /// JSON strings.
  const JsonlChunkedDecoder({this.jsonCodec = const JsonCodec()});

  /// Instantiates the stateful chunking sink that will handle the incoming
  /// stream data.
  ///
  /// This method returns a [_JsonlChunkedDecoderSink], configuring it with the
  /// downstream [sink] and the required [jsonCodec].
  @override
  Sink<String> startChunkedConversion(Sink<dynamic> sink) {
    return _JsonlChunkedDecoderSink(sink, jsonCodec);
  }
}

/// The internal chunk sink that pairs with [JsonlChunkedDecoder].
///
/// Architecturally, this acts as the state machine delegate. It extends
/// [JsonlBaseChunkSink] to automatically buffer incomplete chunks and isolate
/// distinct lines. It then applies the provided [jsonCodec] to map the raw
/// strings to JSON, selectively pushing valid objects to the [outSink].
class _JsonlChunkedDecoderSink extends JsonlBaseChunkSink<dynamic> {
  /// The underlying codec used to deserialize individual lines, inherited
  /// from the parent [JsonlChunkedDecoder].
  final Codec<Object?, String> jsonCodec;

  /// Creates the state machine sink, wrapping the provided [outSink] and
  /// injecting the required [jsonCodec].
  _JsonlChunkedDecoderSink(super.outSink, this.jsonCodec);

  /// Receives an isolated, fully-formed line from the parent [JsonlBaseChunkSink].
  ///
  /// This attempts to parse the [line] into a dynamic JSON object using [jsonCodec].
  /// If the result is not `null`, it is eagerly forwarded to the downstream output sink.
  @override
  void processLine(String line) {
    final json = jsonCodec.decode(line);
    if (json != null) {
      outSink.add(json);
    }
  }
}
