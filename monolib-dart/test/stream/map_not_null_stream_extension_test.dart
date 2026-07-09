import 'dart:async';

import 'package:monolib_dart/stream.dart';
import 'package:test/test.dart';

void main() {
  group('MapNotNullStreamExtension', () {
    test('mapNotNull maps events and filters out null results', () async {
      final stream = Stream<int>.fromIterable([1, 2, 3, 4, 5]);

      final mappedStream = stream.mapNotNull<int>((event) {
        if (event % 2 == 0) {
          return event * 2;
        }
        return null;
      });

      final result = await mappedStream.toList();

      expect(result, equals([4, 8]));
    });

    test('mapNotNull handles mapping to different types', () async {
      final stream =
          Stream<String>.fromIterable(['apple', 'banana', 'kiwi', 'pear']);

      final mappedStream = stream.mapNotNull<int>((event) {
        if (event.length > 4) {
          return event.length;
        }
        return null;
      });

      final result = await mappedStream.toList();

      expect(result, equals([5, 6]));
    });

    test('mapNotNull works with empty streams', () async {
      final emptyStream = Stream<int>.empty();

      final mappedStream =
          emptyStream.mapNotNull<String>((event) => event.toString());
      final result = await mappedStream.toList();

      expect(result, isEmpty);
    });
  });
}
