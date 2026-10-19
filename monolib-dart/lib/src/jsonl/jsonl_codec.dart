import 'dart:convert';

import 'package:monolib_dart/src/jsonl/jsonl_decoder.dart';
import 'package:monolib_dart/src/jsonl/jsonl_encoder.dart';

/// A [Codec] that encodes and decodes JSON Lines (JSONL) strings.
///
/// [JsonlCodec] provides bidirectional conversion between a list of
/// JSON-serializable objects and a newline-delimited JSONL [String] by
/// delegating to [JsonlEncoder] and [JsonlDecoder].
///
/// When encoding, it serializes each element in a [List] to a single-line JSON
/// string terminated by `\n`. When decoding, it splits a JSONL [String] into
/// lines, skips blank lines, and parses each line into a `List<dynamic>`.
///
/// Example:
/// ```dart
/// const codec = JsonlCodec();
///
/// // Encoding
/// final jsonlString = codec.encode([
///   {'id': 1, 'name': 'Alice'},
///   {'id': 2, 'name': 'Bob'},
/// ]);
/// // Result: '{"id":1,"name":"Alice"}\n{"id":2,"name":"Bob"}\n'
///
/// // Decoding
/// final objects = codec.decode(jsonlString);
/// // Result: [{'id': 1, 'name': 'Alice'}, {'id': 2, 'name': 'Bob'}]
/// ```
class JsonlCodec extends Codec<List<dynamic>, String> {
  final Codec<Object?, String> _jsonCodec;

  /// Creates a [JsonlCodec] for encoding and decoding JSONL strings.
  ///
  /// Uses [jsonCodec] (defaulting to `const JsonCodec()`) to serialize and
  /// deserialize each individual line.
  const JsonlCodec({Codec<Object?, String> jsonCodec = const JsonCodec()})
      : _jsonCodec = jsonCodec;

  /// Returns a [JsonlDecoder] configured with [_jsonCodec] that parses a JSONL
  /// [String] into a list of decoded JSON objects.
  @override
  Converter<String, List<dynamic>> get decoder => JsonlDecoder(_jsonCodec);

  /// Returns a [JsonlEncoder] configured with [_jsonCodec] that converts a list
  /// of JSON-serializable objects into a JSONL [String].
  @override
  Converter<List<dynamic>, String> get encoder => JsonlEncoder(_jsonCodec);
}
