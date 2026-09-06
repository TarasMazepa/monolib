import 'package:monolib_dart/stream.dart';
import 'package:test/test.dart';

void main() {
  group('OnStream', () {
    test('lastOrNull returns the last element of the stream', () async {
      final stream = Stream.fromIterable([1, 2, 3]);
      final result = await stream.lastOrNull;
      expect(result, 3);
    });

    test('lastOrNull returns null for an empty stream', () async {
      final stream = Stream<int>.empty();
      final result = await stream.lastOrNull;
      expect(result, isNull);
    });

    test('mappedLastOrNull returns the last non-null mapped value', () async {
      final stream = Stream.fromIterable([1, 2, 3, 4, 5]);
      final result =
          await stream.mappedLastOrNull((e) => e % 2 == 0 ? e * 10 : null);
      expect(result, 40); // 4 * 10 is the last non-null mapped value
    });

    test('mappedLastOrNull returns null for an empty stream', () async {
      final stream = Stream<int>.empty();
      final result = await stream.mappedLastOrNull((e) => e.toString());
      expect(result, isNull);
    });

    test('mappedLastOrNull returns null if all mapped values are null',
        () async {
      final stream = Stream.fromIterable([1, 3, 5]);
      final result =
          await stream.mappedLastOrNull((e) => e % 2 == 0 ? e * 10 : null);
      expect(result, isNull);
    });
  });
}
