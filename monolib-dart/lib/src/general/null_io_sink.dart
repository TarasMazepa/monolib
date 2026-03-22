import 'dart:async';
import 'dart:convert';
import 'dart:io';

class NullIOSink implements IOSink {
  @override
  Encoding encoding = utf8;

  // --- StreamSink / Byte Methods ---

  @override
  void add(List<int> data) {}

  @override
  void addError(Object error, [StackTrace? stackTrace]) {}

  @override
  Future<void> addStream(Stream<List<int>> stream) {
    return stream.drain();
  }

  @override
  Future<void> close() async {}

  @override
  Future<void> get done => Future.value();

  @override
  Future<void> flush() async {}

  // --- StringSink / Text Methods ---

  @override
  void write(Object? object) {}

  @override
  void writeAll(Iterable objects, [String separator = ""]) {}

  @override
  void writeCharCode(int charCode) {}

  @override
  void writeln([Object? object = ""]) {}
}
