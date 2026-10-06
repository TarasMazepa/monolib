import 'dart:async';
import 'dart:convert';

import 'package:monolib_dart/stream.dart';

/// A [StringSink] that UTF-8 encodes everything written to it and adds the
/// resulting bytes to an [EventSink] of bytes.
///
/// This is useful for streaming text, e.g. output of `jsonEncodeAsync`,
/// directly into a byte sink such as an HTTP request body.
class Utf8StreamStringSink implements StringSink {
  final EventSink<List<int>> _sink;
  final void Function(Object error, StackTrace stackTrace)? _onError;

  /// Creates a [Utf8StreamStringSink] that adds encoded bytes to [_sink].
  ///
  /// [onError] is called when adding to [_sink] fails. Such errors are
  /// ignored, so without [onError] they are silently dropped.
  const Utf8StreamStringSink(
    this._sink, {
    void Function(Object error, StackTrace stackTrace)? onError,
  }) : _onError = onError;

  @override
  void write(Object? object) {
    _sink.tryAdd(utf8.encode('$object'), ignoreError: true, onError: _onError);
  }

  @override
  void writeAll(Iterable<dynamic> objects, [String separator = '']) {
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
    _sink.tryAdd(
      utf8.encode(String.fromCharCode(charCode)),
      ignoreError: true,
      onError: _onError,
    );
  }

  @override
  void writeln([Object? object = '']) {
    write(object);
    write('\n');
  }
}
