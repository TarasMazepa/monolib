import 'package:monolib_dart/stream.dart';
import 'package:test/test.dart';

void main() {
  group('OnStreamOfLists', () {
    group('flattenToList', () {
      test('flattens multiple lists into a single list', () async {
        final stream = Stream.fromIterable([
          [1, 2],
          [3],
          [4, 5],
        ]);
        final result = await stream.flattenToList();
        expect(result, [1, 2, 3, 4, 5]);
      });

      test('handles empty lists', () async {
        final stream = Stream.fromIterable([
          <int>[],
          [1, 2],
          <int>[],
          [3],
        ]);
        final result = await stream.flattenToList();
        expect(result, [1, 2, 3]);
      });

      test('handles empty stream', () async {
        final stream = Stream.fromIterable(<List<int>>[]);
        final result = await stream.flattenToList();
        expect(result, <int>[]);
      });

      test('propagates errors', () async {
        final stream = Stream<List<int>>.error(Exception('test error'));
        expect(stream.flattenToList(), throwsA(isA<Exception>()));
      });

      test(
          'respects cancelOnError: false and does not crash on multiple errors',
          () async {
        final stream = Stream<List<int>>.multi((controller) {
          controller.add([1]);
          controller.addError(Exception('first error'));
          controller.add([2]); // Should be ignored
          controller.addError(
              Exception('second error')); // Should not throw StateError
          controller.close();
        });

        await expectLater(
          stream.flattenToList(cancelOnError: false),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('first error'),
            ),
          ),
        );
      });

      test('supports sync completer', () async {
        final stream = Stream.fromIterable([
          [1],
          [2]
        ]);
        final result = await stream.flattenToList(sync: true);
        expect(result, [1, 2]);
      });
    });

    group('asAccumulating', () {
      test('accumulates lists simply', () async {
        final stream = Stream.fromIterable([
          [1, 2],
          [3],
          [4, 5],
        ]);
        final result = await stream
            .asAccumulating()
            .map((l) => [...l])
            .toList();
        expect(result, [
          [1, 2],
          [1, 2, 3],
          [1, 2, 3, 4, 5],
        ]);
      });

      test('accumulates lists with refresh', () async {
        final stream = Stream.fromIterable([
          <int>[],
          [1, 2],
          [3],
          <int>[],
          [10],
        ]);
        final result = await stream
            .asAccumulating(emptyMeansRefresh: true)
            .map((l) => [...l])
            .toList();
        expect(result, [
          <int>[],
          [1, 2],
          [1, 2, 3],
          [10],
        ]);
      });
    });

    group('mapLists', () {
      test('maps lists and skips mapped to empty by default', () async {
        final stream = Stream.fromIterable([
          <int>[],
          [1, 2, 3],
          [4, 5],
          [6],
        ]);

        final result = await stream
            .mapLists<int>((list) => list.where((x) => x.isEven).toList())
            .toList();

        // <int>[] preserved (incoming empty)
        // [1, 2, 3] -> [2]
        // [4, 5] -> [4]
        // [6] -> [6]
        expect(result, [
          <int>[],
          [2],
          [4],
          [6],
        ]);
      });

      test('skips event when non-empty list maps to empty', () async {
        final stream = Stream.fromIterable([
          [1, 3, 5],
          [2, 4],
          [7],
        ]);

        final result = await stream
            .mapLists<int>((list) => list.where((x) => x.isEven).toList())
            .toList();

        // [1, 3, 5] maps to [] -> skipped!
        // [2, 4] maps to [2, 4]
        // [7] maps to [] -> skipped!
        expect(result, [
          [2, 4],
        ]);
      });

      test('emits empty list when skipMappedToEmpty is false', () async {
        final stream = Stream.fromIterable([
          [1, 3, 5],
          [2, 4],
        ]);

        final result = await stream
            .mapLists<int>(
              (list) => list.where((x) => x.isEven).toList(),
              skipMappedToEmpty: false,
            )
            .toList();

        expect(result, [
          <int>[],
          [2, 4],
        ]);
      });
    });

    group('whereElements', () {
      test('returns unchanged stream if predicate is null', () async {
        final stream = Stream.fromIterable([
          [1, 2],
          [3, 4],
        ]);

        final result = await stream.whereElements(null).toList();
        expect(result, [
          [1, 2],
          [3, 4],
        ]);
      });

      test('filters elements and skips empty results', () async {
        final stream = Stream.fromIterable([
          <int>[],
          [1, 2, 3],
          [5, 7],
          [4, 6],
        ]);

        final result = await stream.whereElements((x) => x.isEven).toList();

        // <int>[] -> preserved
        // [1, 2, 3] -> [2]
        // [5, 7] -> [] -> skipped
        // [4, 6] -> [4, 6]
        expect(result, [
          <int>[],
          [2],
          [4, 6],
        ]);
      });
    });
  });
}
