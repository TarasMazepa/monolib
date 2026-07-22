import 'dart:async';
import 'dart:convert';
import 'async_json_writable.dart';

/// Streams a `Stream<String>` directly to the JSON sink as a single, properly escaped JSON string.
class StreamingJsonString implements AsyncJsonWritable {
  final Stream<String> stream;

  const StreamingJsonString(this.stream);

  @override
  Future<void> writeJsonAsync(
      StringSink sink, JsonEncoderCallback encode) async {
    sink.write('"');
    await for (final chunk in stream) {
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
