import 'dart:convert';

import 'package:monolib_dart/src/common/list_accumulator_sink.dart';
import 'package:monolib_dart/src/jsonl/jsonl_chunked_decoder.dart';

/// A synchronous [Converter] that decodes a JSON Lines (JSONL) [String] into a
/// `List<dynamic>` of decoded JSON objects.
///
/// [JsonlDecoder] serves as the synchronous decoder for `JsonlCodec.decoder`.
/// It delegates parsing to [JsonlChunkedDecoder] and collects all emitted JSON
/// objects in memory using a [ListAccumulatorSink].
///
/// Because it buffers the entire result set in memory before returning, use
/// the stream-based [JsonlChunkedDecoder] instead when processing large files
/// or streams.
///
/// Example:
/// ```dart
/// const decoder = JsonlDecoder(JsonCodec());
/// final objects = decoder.convert('{"name":"Alice"}\n{"name":"Bob"}\n');
/// print(objects); // [{'name': 'Alice'}, {'name': 'Bob'}]
/// ```
class JsonlDecoder extends Converter<String, List<dynamic>> {
  final Codec<Object?, String> _jsonCodec;

  /// Creates a [JsonlDecoder] configured with [jsonCodec].
  const JsonlDecoder(Codec<Object?, String> jsonCodec) : _jsonCodec = jsonCodec;

  /// Synchronously decodes the JSONL string [items] into a list of parsed JSON objects.
  ///
  /// Feeds [items] through [JsonlChunkedDecoder.startChunkedConversion] and
  /// accumulates the emitted objects in a [ListAccumulatorSink]. Empty lines
  /// and lines that decode to `null` are skipped. Returns an empty list if
  /// [items] is empty or contains only empty or `null` lines.
  ///
  /// Throws a [FormatException] if any non-empty line contains invalid JSON.
  @override
  List<dynamic> convert(String items) {
    final sink = ListAccumulatorSink<dynamic>();
    JsonlChunkedDecoder(jsonCodec: _jsonCodec).startChunkedConversion(sink)
      ..add(items)
      ..close();
    return sink.results;
  }
}
