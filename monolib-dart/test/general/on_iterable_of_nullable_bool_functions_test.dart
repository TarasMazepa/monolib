import 'package:monolib_dart/monolib_dart.dart';
import 'package:test/test.dart';

void main() {
  group('OnIterableOfNullableBoolFunctions', () {
    group('combinedEvery', () {
      test('empty returns null', () {
        final predicates = <bool Function(int)?>[];
        expect(predicates.combinedEvery, isNull);
      });

      test('only nulls returns null', () {
        final predicates = <bool Function(int)?>[null, null];
        expect(predicates.combinedEvery, isNull);
      });

      test('single predicate', () {
        final predicates = <bool Function(int)?>[(x) => x > 0];
        final combined = predicates.combinedEvery!;
        expect(combined(5), isTrue);
        expect(combined(-1), isFalse);
      });

      test('2 predicates', () {
        final predicates = <bool Function(int)?>[
          (x) => x > 0,
          null,
          (x) => x < 10,
        ];
        final combined = predicates.combinedEvery!;
        expect(combined(5), isTrue);
        expect(combined(-1), isFalse);
        expect(combined(15), isFalse);
      });

      test('3 predicates', () {
        final predicates = <bool Function(int)?>[
          (x) => x > 0,
          (x) => x < 10,
          (x) => x.isEven,
        ];
        final combined = predicates.combinedEvery!;
        expect(combined(4), isTrue);
        expect(combined(3), isFalse);
        expect(combined(12), isFalse);
      });

      test('4 predicates', () {
        final predicates = <bool Function(int)?>[
          (x) => x > 0,
          (x) => x < 20,
          (x) => x.isEven,
          (x) => x % 3 == 0,
        ];
        final combined = predicates.combinedEvery!;
        expect(combined(6), isTrue);
        expect(combined(12), isTrue);
        expect(combined(8), isFalse);
      });

      test('many predicates (fallback)', () {
        final predicates = <bool Function(int)?>[
          (x) => x > 0,
          (x) => x < 50,
          (x) => x.isEven,
          (x) => x % 3 == 0,
          (x) => x != 12,
        ];
        final combined = predicates.combinedEvery!;
        expect(combined(6), isTrue);
        expect(combined(18), isTrue);
        expect(combined(12), isFalse);
      });
    });

    group('combinedAny', () {
      test('empty returns null', () {
        final predicates = <bool Function(int)?>[];
        expect(predicates.combinedAny, isNull);
      });

      test('only nulls returns null', () {
        final predicates = <bool Function(int)?>[null, null];
        expect(predicates.combinedAny, isNull);
      });

      test('single predicate', () {
        final predicates = <bool Function(int)?>[(x) => x > 0];
        final combined = predicates.combinedAny!;
        expect(combined(5), isTrue);
        expect(combined(-1), isFalse);
      });

      test('2 predicates', () {
        final predicates = <bool Function(int)?>[
          (x) => x < 0,
          null,
          (x) => x > 10,
        ];
        final combined = predicates.combinedAny!;
        expect(combined(-5), isTrue);
        expect(combined(15), isTrue);
        expect(combined(5), isFalse);
      });

      test('3 predicates', () {
        final predicates = <bool Function(int)?>[
          (x) => x == 1,
          (x) => x == 2,
          (x) => x == 3,
        ];
        final combined = predicates.combinedAny!;
        expect(combined(2), isTrue);
        expect(combined(4), isFalse);
      });

      test('4 predicates', () {
        final predicates = <bool Function(int)?>[
          (x) => x == 1,
          (x) => x == 2,
          (x) => x == 3,
          (x) => x == 4,
        ];
        final combined = predicates.combinedAny!;
        expect(combined(4), isTrue);
        expect(combined(5), isFalse);
      });

      test('many predicates (fallback)', () {
        final predicates = <bool Function(int)?>[
          (x) => x == 1,
          (x) => x == 2,
          (x) => x == 3,
          (x) => x == 4,
          (x) => x == 5,
        ];
        final combined = predicates.combinedAny!;
        expect(combined(5), isTrue);
        expect(combined(6), isFalse);
      });
    });
  });
}
