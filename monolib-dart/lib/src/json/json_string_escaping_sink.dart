import 'dart:convert';

/// A proxy [StringSink] that intercepts writes, escapes them for JSON string
/// literals, and forwards the escaped characters to an underlying sink.
class JsonStringEscapingSink implements StringSink {
  static const _encoder = JsonEncoder();

  final StringSink _inner;

  /// Creates a [JsonStringEscapingSink] that writes escaped characters to the
  /// underlying sink.
  const JsonStringEscapingSink(this._inner);

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
