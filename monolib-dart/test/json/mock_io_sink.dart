import 'dart:convert';
import 'dart:io';

class MockIOSink implements IOSink {
  final StringBuffer _buffer;

  MockIOSink(this._buffer);

  @override
  void write(Object? object) => _buffer.write(object);

  @override
  void writeln([Object? object = ""]) => _buffer.writeln(object);

  @override
  void writeAll(Iterable objects, [String separator = ""]) =>
      _buffer.writeAll(objects, separator);

  @override
  void writeCharCode(int charCode) => _buffer.writeCharCode(charCode);

  @override
  void add(List<int> data) {}

  @override
  void addError(Object error, [StackTrace? stackTrace]) {}

  @override
  Future<void> addStream(Stream<List<int>> stream) async {}

  @override
  Future<void> flush() async {}

  @override
  Future<void> close() async {}

  @override
  Future<void> get done async {}

  @override
  Encoding get encoding => utf8;

  @override
  set encoding(Encoding encoding) {}
}
