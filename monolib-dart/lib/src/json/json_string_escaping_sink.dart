import 'dart:convert';

/// A proxy [StringSink] that intercepts writes, escapes them for JSON string
/// literals, and forwards the escaped characters to an underlying sink.
///
/// [JsonStringEscapingSink] provides push-based streaming of large text into an
/// active JSON serialization pipeline (such as `jsonEncodeAsync`) without
/// buffering the entire string in memory. It strips the surrounding quotes
/// produced by [JsonEncoder], allowing callers to iteratively append escaped
/// chunks inside an open JSON string literal.
///
/// For pull-based stream ingestion, see `StreamingJsonString`.
///
/// Example:
/// ```dart
/// final buffer = StringBuffer();
/// buffer.write('{"largeText":"');
///
/// final escapingSink = JsonStringEscapingSink(buffer);
/// escapingSink.write('First chunk.\n');
/// escapingSink.write('Second chunk with "quotes".');
///
/// buffer.write('"}');
/// ```
class JsonStringEscapingSink implements StringSink {
  static const _encoder = JsonEncoder();

  final StringSink _inner;

  /// Creates a [JsonStringEscapingSink] that writes escaped characters to the
  /// underlying sink.
  ///
  /// The underlying sink receives the JSON-escaped output stripped of
  /// surrounding quotes.
  const JsonStringEscapingSink(this._inner);

  /// Converts the given [object] to a string, safely escapes it for JSON embedding,
  /// and writes the resulting characters to the underlying sink.
  ///
  /// If [object] is `null`, writes the literal `"null"` (without quotes).
  /// If its string representation is empty, nothing is written.
  @override
  void write(Object? object) {
    final escaped = _encoder.convert(
      switch (object) {
        null => null,
        final str => str.toString(),
      },
    );
    if (escaped == '""') return;

    if (escaped == 'null') {
      _inner.write(escaped);
      return;
    }

    // With non-empty str, _encoder.convert(str) is always >= 3 chars ("x")
    _inner.write(escaped.substring(1, escaped.length - 1));
  }

  /// Iterates over [objects] and sequentially writes their escaped string representations
  /// to the underlying sink.
  ///
  /// If a [separator] is provided, it is inserted between each object. Both the elements
  /// and the [separator] undergo the same JSON escaping process via [write]. If [objects]
  /// is empty, this method performs no action.
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

  /// Converts a single UTF-16 [charCode] into its string equivalent and writes its
  /// JSON-escaped representation to the underlying sink via [write].
  @override
  void writeCharCode(int charCode) {
    write(String.fromCharCode(charCode));
  }

  /// Writes the JSON-escaped string representation of [object] to the underlying sink,
  /// immediately followed by an escaped newline character (`\n`).
  ///
  /// If [object] is omitted, only the escaped newline is written.
  @override
  void writeln([Object? object = ""]) {
    write(object);
    write('\n');
  }
}
