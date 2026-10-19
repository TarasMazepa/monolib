import 'dart:convert';

/// A synchronous [Converter] that encodes a list of JSON-serializable objects
/// into a JSON Lines (JSONL) [String].
///
/// [JsonlEncoder] serves as the synchronous encoder for `JsonlCodec.encoder`.
/// It serializes each element in a [List] into a single-line JSON string using
/// [jsonCodec] and appends a trailing newline (`\n`).
///
/// Because it buffers the entire output string in memory, use
/// `jsonlEncodeAsync` instead when streaming large datasets.
///
/// Example:
/// ```dart
/// const encoder = JsonlEncoder(JsonCodec());
/// final jsonlData = encoder.convert([
///   {'id': 'alpha', 'value': 100},
///   {'id': 'beta', 'value': 200},
/// ]);
/// // Result: '{"id":"alpha","value":100}\n{"id":"beta","value":200}\n'
/// ```
class JsonlEncoder extends Converter<List<dynamic>, String> {
  /// The underlying [Codec] used to encode individual elements into JSON strings.
  final Codec<Object?, String> jsonCodec;

  /// Creates a [JsonlEncoder] configured with [jsonCodec].
  const JsonlEncoder(this.jsonCodec);

  /// Synchronously encodes [items] into a JSONL [String].
  ///
  /// Encodes each element in [items] using [jsonCodec] and writes it followed
  /// by a newline (`\n`) to a [StringBuffer].
  @override
  String convert(List<dynamic> items) {
    final result = StringBuffer();
    for (final item in items) {
      result.writeln(jsonCodec.encode(item));
    }
    return result.toString();
  }
}
