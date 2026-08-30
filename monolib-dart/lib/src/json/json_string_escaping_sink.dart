import 'dart:convert';

/// A proxy [StringSink] that intercepts writes, safely escapes them for JSON,
/// and forwards the raw escaped characters to an underlying sink.
///
/// This is particularly useful for streaming large text payloads directly into
/// a JSON string field without buffering the entire string in memory.
class JsonStringEscapingSink implements StringSink {
  final StringSink _inner;

  /// Creates a [JsonStringEscapingSink] that writes escaped characters to [_inner].
  const JsonStringEscapingSink(this._inner);

  @override
  void write(Object? object) {
    final str = object?.toString();
    if (str == null || str.isEmpty) return;

    // jsonEncode returns a fully escaped string wrapped in double quotes.
    // e.g., `"escaped\ntext"`
    final escaped = jsonEncode(str);
    if (escaped.length >= 2) {
      // Strip the first and last quote from the encoded string.
      _inner.write(escaped.substring(1, escaped.length - 1));
    }
  }

  @override
  void writeAll(Iterable<dynamic> objects, [String separator = ""]) {
    final iterator = objects.iterator;
    if (!iterator.moveNext()) return;

    if (separator.isEmpty) {
      do {
        write(iterator.current);
      } while (iterator.moveNext());
    } else {
      write(iterator.current);
      while (iterator.moveNext()) {
        write(separator);
        write(iterator.current);
      }
    }
  }

  @override
  void writeCharCode(int charCode) {
    write(String.fromCharCode(charCode));
  }

  @override
  void writeln([Object? object = ""]) {
    write(object);
    write('\n');
  }
}
