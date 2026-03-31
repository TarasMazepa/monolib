import 'dart:io';

import 'package:monolib_dart/io.dart';
import 'package:test/test.dart';

void main() {
  group('OnFunction', () {
    test('withIOSink', () async {
      final file = File('test.txt');
      await (() => file.openWrite()).withIOSink((sink) async {
        sink.write('hello');
      });
      expect(await file.readAsString(), 'hello');
      await file.delete();
    });
  });
}
