import 'package:monolib_dart/src/general/on_nullable_iterable.dart';
import 'package:test/test.dart';

void main() {
  group('OnNullableIterable', () {
    test('isNullOrEmpty', () {
      Iterable<int>? nullIterable;
      expect(nullIterable.isNullOrEmpty, isTrue);

      Iterable<int>? emptyIterable = [];
      expect(emptyIterable.isNullOrEmpty, isTrue);

      Iterable<int>? notEmptyIterable = [1];
      expect(notEmptyIterable.isNullOrEmpty, isFalse);
    });

    test('isNotNullNorEmpty', () {
      Iterable<int>? nullIterable;
      expect(nullIterable.isNotNullNorEmpty, isFalse);

      Iterable<int>? emptyIterable = [];
      expect(emptyIterable.isNotNullNorEmpty, isFalse);

      Iterable<int>? notEmptyIterable = [1];
      expect(notEmptyIterable.isNotNullNorEmpty, isTrue);
    });
  });
}
