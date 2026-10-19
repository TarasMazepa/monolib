import 'dart:async';
import 'dart:convert';

import 'package:monolib_dart/src/json/async_json_writable.dart';

/// An [AsyncJsonWritable] that streams a [Stream] of strings directly into an
/// active JSON sink as a single, properly escaped JSON string literal.
///
/// Instead of buffering a large string in memory via a synchronous `toJson()`
/// call, [StreamingJsonString] listens to the stream returned by
/// [streamProvider] and writes escaped chunks progressively to the target
/// [StringSink].
///
/// Example:
/// ```dart
/// final jsonObject = {
///   'filename': 'massive_log.txt',
///   'content': StreamingJsonString(
///     () => File('massive_log.txt').openRead().transform(utf8.decoder),
///   ),
/// };
///
/// await jsonEncodeAsync(object: jsonObject, sink: stdout);
/// ```
class StreamingJsonString implements AsyncJsonWritable {
  final Stream<String> Function() _streamProvider;

  /// Creates a [StreamingJsonString] that incrementally encodes and writes
  /// chunks from the stream returned by [streamProvider].
  const StreamingJsonString(Stream<String> Function() streamProvider)
      : _streamProvider = streamProvider;

  /// Asynchronously reads chunks from the underlying stream provider, escapes
  /// them for JSON, and writes them as a single quoted JSON string to [sink].
  ///
  /// Writes an opening double quote, appends the inner escaped content of each
  /// chunk (using [jsonEncode] with its surrounding quotes stripped), and
  /// finishes with a closing double quote.
  @override
  Future<void> writeJsonAsync(
    StringSink sink,
    JsonEncoderCallback encode,
  ) async {
    sink.write('"');
    await for (final chunk in _streamProvider()) {
      // jsonEncode escapes the chunk and adds surrounding quotes (e.g., "chunk\ntext").
      final escaped = jsonEncode(chunk);
      if (escaped.length >= 2) {
        // Strip the first and last character to extract just the escaped inner content
        sink.write(escaped.substring(1, escaped.length - 1));
      }
    }
    sink.write('"');
  }
}
