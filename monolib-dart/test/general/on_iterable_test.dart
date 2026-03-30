import 'package:monolib_dart/monolib_dart.dart';
import 'package:test/test.dart';

void main() {
  group('OnIterable', () {
    test('mapCatching', () {
      final items = ['1', 'a', '2'];
      final errors = [];
      final result = items
          .mapCatching(
            (e) => int.parse(e),
            onError: (error, item) => errors.add(item),
          )
          .toList();

      expect(result, [1, 2]);
      expect(errors, ['a']);
    });

    test('sum', () {
      expect([1, 2, 3].sum(), 6);
      expect([1.5, 2.5].sum(), 4.0);
      expect(() => <int>[].sum(), throwsStateError);
    });

    test('sumBy', () {
      expect(['a', 'bb', 'ccc'].sumBy((e) => e.length), 6);
      expect(() => <String>[].sumBy((e) => e.length), throwsStateError);
    });
  });
}
