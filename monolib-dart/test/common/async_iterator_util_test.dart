import 'dart:async';

import 'package:monolib_dart/src/common/async_iterator_util.dart';
import 'package:test/test.dart';

void main() {
  group('iterateStreamOrIterable', () {
    test('iterates Iterable synchronously and returns null', () {
      final processed = <int>[];
      final items = [1, 2, 3];

      final result = iterateStreamOrIterable(items, (item) {
        processed.add(item as int);
      });

      expect(result, isNull);
      expect(processed, [1, 2, 3]);
    });

    test(
        'awaits Future and returns Future when handler returns Future for Iterable',
        () async {
      final processed = <int>[];
      final items = [1, 2, 3];

      final result = iterateStreamOrIterable(items, (item) async {
        await Future<void>.delayed(Duration(milliseconds: 1));
        processed.add(item as int);
      });

      expect(result, isA<Future<void>>());
      await result;
      expect(processed, [1, 2, 3]);
    });

    test(
        'processes items synchronously until a Future is returned midway through Iterable',
        () async {
      final processed = <int>[];
      final items = [1, 2, 3, 4];

      final result = iterateStreamOrIterable(items, (item) {
        if (item == 3) {
          return Future<void>.delayed(Duration(milliseconds: 1), () {
            processed.add(item as int);
          });
        }
        processed.add(item as int);
        return null;
      });

      expect(result, isA<Future<void>>());
      // Items before the future were processed synchronously!
      expect(processed, [1, 2]);

      await result;
      expect(processed, [1, 2, 3, 4]);
    });

    test(
        'iterates Stream, returns Future, and calls onStreamItemDone after each event',
        () async {
      final processed = <int>[];
      final doneCounts = <int>[];
      int flushCount = 0;

      final stream = Stream.fromIterable([10, 20, 30]);

      final result = iterateStreamOrIterable(
        stream,
        (item) {
          processed.add(item as int);
        },
        onStreamItemDone: () {
          flushCount++;
          doneCounts.add(flushCount);
        },
      );

      expect(result, isA<Future<void>>());
      await result;
      expect(processed, [10, 20, 30]);
      expect(doneCounts, [1, 2, 3]);
    });

    test('does not invoke onStreamItemDone for empty Stream', () async {
      int flushCount = 0;

      await iterateStreamOrIterable(
        Stream<int>.empty(),
        (item) {},
        onStreamItemDone: () {
          flushCount++;
        },
      );

      expect(flushCount, 0);
    });

    test('throws ArgumentError for unsupported item types', () async {
      expect(
        () => iterateStreamOrIterable(12345, (item) {}),
        throwsArgumentError,
      );
    });
  });
}
