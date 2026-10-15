import 'dart:convert';

import 'package:monolib_dart/src/jsonl/jsonl_decoder.dart';
import 'package:monolib_dart/src/jsonl/jsonl_encoder.dart';

/// A [Codec] that encodes and decodes JSON Lines (JSONL) formatted strings.
///
/// Architecturally, this codec serves as the standard integration point between
/// the `monolib_dart` JSONL utilities and Dart's core `dart:convert` library.
/// By extending [Codec], it allows JSONL processing to participate in standard
/// stream transformations (via `Codec.fuse` or `Codec.bind`) and provides a
/// unified interface for in-memory serialization and deserialization.
///
/// In the context of this repository, it acts as a facade that delegates structural
/// parsing and generation to [JsonlDecoder] and [JsonlEncoder]. When parsing, it
/// converts a single [String] containing newline-separated JSON strings into a
/// `List<dynamic>` (where each element is a parsed JSON object). Conversely, it
/// encodes an `Iterable` or `List` of JSON-serializable objects into a single
/// newline-delimited [String].
///
/// **Real-world example:**
/// ```dart
/// final codec = JsonlCodec();
///
/// // Encoding a list of objects to a JSONL string for file storage.
/// final objects = [{'id': 1}, {'id': 2}];
/// final String fileContent = codec.encode(objects);
/// // Result: '{"id":1}\n{"id":2}\n'
///
/// // Decoding an in-memory JSONL string back into a list of objects.
/// final List<dynamic> parsed = codec.decode(fileContent);
/// // Result: [{'id': 1}, {'id': 2}]
/// ```
class JsonlCodec extends Codec<List<dynamic>, String> {
  /// The underlying [Codec] used to serialize and deserialize individual JSON lines.
  ///
  /// This delegates the internal mapping of strings to objects to standard JSON
  /// tools. In most cases, this defaults to dart:convert's [JsonCodec], but it
  /// can be overridden to inject custom serializers or formatting configurations
  /// (such as customized `toEncodable` logic).
  final Codec<Object?, String> jsonCodec;

  /// Creates a new [JsonlCodec] for converting between JSONL strings and object lists.
  ///
  /// The [jsonCodec] parameter allows injection of a custom JSON processing
  /// strategy. If omitted, it defaults to a standard [JsonCodec] instance.
  const JsonlCodec({this.jsonCodec = const JsonCodec()});

  /// Returns a [JsonlDecoder] configured with the underlying [jsonCodec].
  ///
  /// The returned decoder is responsible for splitting the input [String] into
  /// distinct lines, ignoring blank lines, and parsing each line sequentially
  /// into a `List<dynamic>`.
  @override
  Converter<String, List<dynamic>> get decoder => JsonlDecoder(jsonCodec);

  /// Returns a [JsonlEncoder] configured with the underlying [jsonCodec].
  ///
  /// The returned encoder is responsible for serializing each element of the
  /// input list to a single-line JSON string and appending a newline character,
  /// resulting in a properly formatted JSONL [String].
  @override
  Converter<List<dynamic>, String> get encoder => JsonlEncoder(jsonCodec);
}
