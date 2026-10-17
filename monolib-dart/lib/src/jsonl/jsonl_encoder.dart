/// Provides the [JsonlEncoder] class for serializing Dart object lists into JSON Lines format.
///
/// This library acts as the encoding counterpart to the JSON Lines (JSONL)
/// utilities within `monolib_dart`, converting in-memory sequences of objects
/// into newline-delimited strings suitable for logging, data-exchange, or
/// file storage.
library;

import 'dart:convert';

/// A synchronous converter that transforms a list of JSON-serializable objects
/// into a single JSON Lines (JSONL) formatted string.
///
/// Architecturally, this class powers the `encoder` property of `JsonlCodec`.
/// It iterates over a given sequence of objects, serializes each element into
/// a compact (single-line) JSON string using an underlying [Codec], and appends
/// a trailing newline character.
///
/// It strictly outputs a single batched [String] containing multiple lines,
/// which makes it primarily useful for in-memory batch conversions. For true
/// asynchronous, chunk-based streaming of large datasets without blocking
/// or excessive memory buffering, consider the repository's streaming
/// alternatives like `jsonEncodeAsync`.
///
/// **Real-world example:**
/// ```dart
/// // Typically accessed via JsonlCodec rather than instantiated directly.
/// final codec = JsonlCodec();
///
/// final objects = [
///   {'id': 'alpha', 'value': 100},
///   {'id': 'beta', 'value': 200},
/// ];
///
/// // The codec's encoder (an instance of JsonlEncoder) writes each map
/// // to a separate line separated by `\n`.
/// final jsonlString = codec.encode(objects);
/// ```
class JsonlEncoder extends Converter<List<dynamic>, String> {
  /// The underlying [Codec] used to serialize individual elements into JSON strings.
  ///
  /// This field delegates the actual string generation to Dart's standard
  /// JSON machinery. It typically defaults to `JsonCodec` when instantiated by
  /// `JsonlCodec`, but can be substituted with custom implementations to enforce
  /// specific formatting rules (e.g., `toEncodable` fallbacks for custom
  /// domain objects).
  final Codec<Object?, String> jsonCodec;

  /// Creates a new [JsonlEncoder] initialized with the specified [jsonCodec].
  ///
  /// The [jsonCodec] parameter dictates how each individual object is translated
  /// into a string before the newline delimiter is appended.
  const JsonlEncoder(this.jsonCodec);

  /// Transforms the given sequence of [items] into a monolithic JSONL string.
  ///
  /// This method iterates sequentially through [items]. For each element, it
  /// invokes the `encode` method on the injected [jsonCodec] and appends the
  /// serialized output along with a newline (`\n`) to an internal [StringBuffer].
  ///
  /// Returns a completed [String] containing all elements. Note that this
  /// fully buffers the output in memory, so it is generally unsuited for
  /// massive lists that exceed available RAM.
  @override
  String convert(List<dynamic> items) {
    final result = StringBuffer();
    for (final item in items) {
      result.writeln(jsonCodec.encode(item));
    }
    return result.toString();
  }
}
