import 'package:monolib_dart/monolib_dart.dart';
import 'package:test/test.dart';

void main() {
  group('OnIterableMapper', () {
    test('combine empty', () {
      final mappers = <int Function(int)?>[];
      final combined = mappers.combined;
      expect(combined, isNull);
    });

    test('combine with nulls', () {
      final mappers = <int Function(int)?>[null, null];
      final combined = mappers.combined;
      expect(combined, isNull);
    });

    test('combine 1 mapper', () {
      final mappers = <int Function(int)?>[(x) => x + 1];
      final combined = mappers.combined!;
      expect(combined(5), 6);
    });

    test('combine 2 mappers', () {
      final mappers = <int Function(int)?>[(x) => x + 1, (x) => x * 2];
      final combined = mappers.combined!;
      expect(combined(5), 11);
    });

    test('combine many mappers (fallback)', () {
      final mappers = <int Function(int)?>[
        (x) => x + 1,
        (x) => x * 2,
        (x) => x - 3,
        (x) => x * 10,
        (x) => x ~/ 2,
      ];
      final combined = mappers.combined!;
      // ((5 ~/ 2) * 10 - 3) * 2 + 1
      // 2 * 10 - 3 = 17
      // 17 * 2 = 34
      // 34 + 1 = 35
      expect(combined(5), 35);
    });
  });
}
