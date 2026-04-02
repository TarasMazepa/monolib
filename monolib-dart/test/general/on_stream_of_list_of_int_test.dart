import 'dart:convert';

import 'package:monolib_dart/stream.dart';
import 'package:test/test.dart';

void main() {
  group('OnStreamOfListOfInt', () {
    test('utf8DecodeAndLineSplit decodes utf8 and splits into lines', () async {
      final byteChunks = [
        utf8.encode('hello'),
        utf8.encode(' world\n'),
        utf8.encode('how are '),
        utf8.encode('you?\n'),
        utf8.encode('im good\n'),
      ];

      final stream = Stream.fromIterable(byteChunks);

      final lines = await stream.utf8DecodeAndLineSplit().toList();

      expect(lines, [
        'hello world',
        'how are you?',
        'im good',
      ]);
    });

    test('handles empty stream', () async {
      final stream = Stream<List<int>>.empty();

      final lines = await stream.utf8DecodeAndLineSplit().toList();

      expect(lines, isEmpty);
    });

    test('handles stream with no newlines', () async {
      final byteChunks = [
        utf8.encode('hello'),
        utf8.encode(' world'),
      ];

      final stream = Stream.fromIterable(byteChunks);

      final lines = await stream.utf8DecodeAndLineSplit().toList();

      expect(lines, ['hello world']);
    });
  });
}
