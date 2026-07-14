import 'dart:async';

import 'package:monolib_dart/stream.dart';
import 'package:test/test.dart';

void main() {
  group('StreamWhereTypeExtension', () {
    test('whereType filters elements by type correctly', () async {
      final mixedStream = Stream<Object>.fromIterable([
        1,
        'two',
        3.0,
        4,
        'five',
      ]);

      final intStream = mixedStream.whereType<int>();
      final ints = await intStream.toList();

      expect(ints, equals([1, 4]));
    });

    test('whereType filters string elements correctly', () async {
      final mixedStream = Stream<Object>.fromIterable([
        1,
        'two',
        3.0,
        4,
        'five',
      ]);

      final stringStream = mixedStream.whereType<String>();
      final strings = await stringStream.toList();

      expect(strings, equals(['two', 'five']));
    });

    test('whereType works with empty streams', () async {
      final emptyStream = Stream<Object>.empty();

      final intStream = emptyStream.whereType<int>();
      final ints = await intStream.toList();

      expect(ints, isEmpty);
    });
  });
}
