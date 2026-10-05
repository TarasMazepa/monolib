import 'dart:async';
import 'dart:convert';

import 'package:monolib_dart/stream.dart';

class Utf8StreamStringSink implements StringSink {
  final EventSink<List<int>> _sink;

  Utf8StreamStringSink(this._sink);

  @override
  void write(Object? object) {
    _sink.tryAdd(
      utf8.encode('$object'),
      ignoreError: true,
    );
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
    );
  }

  @override
  void writeln([Object? object = '']) {
    write(object);
    write('\n');
  }
}
