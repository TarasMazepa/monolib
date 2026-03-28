import 'package:monolib_dart/monolib_dart.dart';
import 'package:test/test.dart';

void main() {
  group('OnList', () {
    test('deepEquals', () {
      expect([1, 2, 3].deepEquals([1, 2, 3]), isTrue);
      expect([1, 2, 3].deepEquals([1, 2]), isFalse);
      expect([1, 2, 3].deepEquals([1, 2, 4]), isFalse);

      final list = [1, 2, 3];
      expect(list.deepEquals(list), isTrue);
    });

    test('sorted', () {
      final list = [3, 1, 2];
      final result = list.sorted();
      expect(result, [1, 2, 3]);
      expect(list, [1, 2, 3]); // it mutates the list

      final list2 = [3, 1, 2];
      final result2 = list2.sorted(compare: (a, b) => b.compareTo(a));
      expect(result2, [3, 2, 1]);
    });

    test('sortedBy', () {
      final list = ['ccc', 'a', 'bb'];
      final result = list.sortedBy((e) => e.length);
      expect(result, ['a', 'bb', 'ccc']);
      expect(list, ['a', 'bb', 'ccc']); // it mutates the list
    });

    test('sortedByDescending', () {
      final list = ['a', 'ccc', 'bb'];
      final result = list.sortedByDescending((e) => e.length);
      expect(result, ['ccc', 'bb', 'a']);
      expect(list, ['ccc', 'bb', 'a']); // it mutates the list
    });
  });
}
