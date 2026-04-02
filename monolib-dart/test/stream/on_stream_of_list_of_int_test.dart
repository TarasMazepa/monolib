import 'dart:convert';
import 'package:monolib_dart/stream.dart';
import 'package:test/test.dart';

void main() {
  group('OnStreamOfListOfInt', () {
    test('readLine() returns the first line from a stream of UTF-8 bytes',
        () async {
      final data = 'Hello, World!\nSecond Line\nThird Line';
      final stream = Stream.fromIterable([utf8.encode(data)]);
      final result = await stream.readLine();
      expect(result, 'Hello, World!');
    });

    test('readLine() handles multiple chunks correctly', () async {
      final stream = Stream.fromIterable([
        utf8.encode('Hello'),
        utf8.encode(', '),
        utf8.encode('World!\nSecond'),
        utf8.encode(' Line'),
      ]);
      final result = await stream.readLine();
      expect(result, 'Hello, World!');
    });

    test('readLine() returns the whole string if there is no newline',
        () async {
      final stream = Stream.fromIterable([utf8.encode('No newline here')]);
      final result = await stream.readLine();
      expect(result, 'No newline here');
    });

    test('readLine() throws StateError on an empty stream', () async {
      final stream = Stream<List<int>>.empty();
      expect(() => stream.readLine(), throwsStateError);
    });
  });
}
