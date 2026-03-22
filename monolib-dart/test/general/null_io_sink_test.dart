import 'dart:async';
import 'dart:convert';
import 'package:monolib_dart/null_io_sink.dart';
import 'package:test/test.dart';

void main() {
  test('NullIOSink properties and methods', () async {
    final sink = NullIOSink();

    expect(sink.encoding.name, utf8.name);
    sink.encoding = ascii;
    expect(sink.encoding.name, ascii.name);

    sink.add([1, 2, 3]);
    sink.addError(Exception());

    final stream = Stream.fromIterable([
      [1],
      [2]
    ]);
    await sink.addStream(stream);

    await sink.flush();
    await sink.close();
    await sink.done;

    sink.write('test');
    sink.writeAll(['a', 'b']);
    sink.writeCharCode(65);
    sink.writeln('test');
  });
}
