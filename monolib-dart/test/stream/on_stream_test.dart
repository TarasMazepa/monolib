import 'package:monolib_dart/stream.dart';
import 'package:test/test.dart';

void main() {
  group('StreamLastOrNullExtension', () {
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
  });
}
