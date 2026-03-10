import 'package:monolib_dart/monolib_dart.dart';
import 'package:test/test.dart';

void main() {
  group('OnIterableIterable', () {
    test('mix empty', () {
      final result = <Iterable<int>>[].mixed.toList();
      expect(result, []);
    });

    test('mix one iterable', () {
      final result = [
        [1, 2, 3],
      ].mixed.toList();
      expect(result, [1, 2, 3]);
    });

    test('mix multiple iterables of same length', () {
      final result = [
        [1, 2],
        [3, 4],
        [5, 6],
      ].mixed.toList();
      expect(result, [1, 3, 5, 2, 4, 6]);
    });

    test('mix multiple iterables of different lengths', () {
      final result = [
        [1, 2, 3],
        [4],
        [5, 6],
      ].mixed.toList();
      expect(result, [1, 4, 5, 2, 6, 3]);
    });
  });
}
