import 'dart:convert';

import 'package:monolib_dart/src/common/list_accumulator_sink.dart';
import 'package:monolib_dart/src/jsonl/jsonl_chunked_decoder.dart';

/// A synchronous [Converter] that completely decodes a JSON Lines (JSONL) formatted string
/// into a materialized `List<dynamic>` of JSON objects.
///
/// Architecturally, this class acts as the decoding delegate for [JsonlCodec].
/// To adhere to the DRY principle and avoid duplicating structural parsing logic
/// (such as handling newlines and dropping `null` values), it delegates the actual
/// parsing state machine to [JsonlChunkedDecoder]. It fully buffers the emitted
/// JSON objects in memory using a [ListAccumulatorSink].
///
/// Because it accumulates the entire result set in memory before returning, this
/// decoder is intended for relatively small payloads. For processing massive files
/// or infinite streams where memory consumption is a concern, use the stream-based
/// [JsonlChunkedDecoder] (typically via `JsonlCodec().decoder.bind(stream)`) instead.
///
/// **Real-world example:**
/// ```dart
/// // Typically accessed via the [JsonlCodec] facade:
/// final decoder = JsonlCodec().decoder;
///
/// // Decoding an in-memory JSONL string.
/// final String rawPayload = '{"name":"Alice"}\n{"name":"Bob"}\n';
/// final List<dynamic> parsedList = decoder.convert(rawPayload);
/// // Result: [{'name': 'Alice'}, {'name': 'Bob'}]
/// ```
class JsonlDecoder extends Converter<String, List<dynamic>> {
  /// The underlying [Codec] injected to map individual line strings into JSON objects.
  ///
  /// This defaults to `dart:convert`'s standard `JsonCodec` (when created via
  /// [JsonlCodec]), but can be customized to inject specialized reviver functions
  /// or formatting strategies.
  final Codec<Object?, String> jsonCodec;

  /// Creates a new [JsonlDecoder] configured with the underlying [jsonCodec].
  const JsonlDecoder(this.jsonCodec);

  /// Synchronously decodes the complete JSONL string [items] into a list of parsed JSON objects.
  ///
  /// This method blocks execution and buffers the full result into memory. It dynamically
  /// instantiates a [JsonlChunkedDecoder] and feeds it the entire string at once, aggregating
  /// the outputs into a [ListAccumulatorSink].
  ///
  /// Returns a `List<dynamic>` containing all valid JSON objects successfully decoded from [items].
  /// If the input string is empty or contains only invalid/null JSON lines, an empty list is returned.
  @override
  List<dynamic> convert(String items) {
    final sink = ListAccumulatorSink<dynamic>();
    JsonlChunkedDecoder(jsonCodec: jsonCodec).startChunkedConversion(sink)
      ..add(items)
      ..close();
    return sink.results;
  }
}
