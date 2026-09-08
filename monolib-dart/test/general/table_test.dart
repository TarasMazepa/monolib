import 'package:monolib_dart/monolib_dart.dart';
import 'package:test/test.dart';

void main() {
  group('DenseTable<T>', () {
    test('.filled constructor', () {
      final table = DenseTable<String>.filled(2, 3, 'a');
      expect(table.rows, 2);
      expect(table.columns, 3);
      expect(table.get(0, 0), 'a');
      expect(table.get(1, 2), 'a');
    });

    test('.generate constructor', () {
      final table = DenseTable<int>.generate(2, 2, (row, col) => row + col);
      expect(table.get(0, 0), 0);
      expect(table.get(0, 1), 1);
      expect(table.get(1, 0), 1);
      expect(table.get(1, 1), 2);
    });

    test('get and set', () {
      final table = DenseTable<int>.filled(2, 2, 0);
      table.set(1, 1, 42);
      expect(table.get(1, 1), 42);
      expect(table.get(0, 0), 0);
    });

    test('bounds checks', () {
      final table = DenseTable<int>.filled(2, 2, 0);
      expect(() => table.get(-1, 0), throwsRangeError);
      expect(() => table.get(2, 0), throwsRangeError);
      expect(() => table.get(0, -1), throwsRangeError);
      expect(() => table.get(0, 2), throwsRangeError);

      expect(() => table.set(-1, 0, 1), throwsRangeError);
      expect(() => table.set(2, 0, 1), throwsRangeError);
      expect(() => table.set(0, -1, 1), throwsRangeError);
      expect(() => table.set(0, 2, 1), throwsRangeError);
    });

    test('empty table bounds checks', () {
      final table = DenseTable<int>.filled(0, 0, 0);
      expect(() => table.get(0, 0), throwsRangeError);
      expect(() => table.set(0, 0, 1), throwsRangeError);

      final tableRow0 = DenseTable<int>.filled(0, 2, 0);
      expect(() => tableRow0.get(0, 0), throwsRangeError);
      expect(() => tableRow0.set(0, 0, 1), throwsRangeError);

      final tableCol0 = DenseTable<int>.filled(2, 0, 0);
      expect(() => tableCol0.get(0, 0), throwsRangeError);
      expect(() => tableCol0.set(0, 0, 1), throwsRangeError);
    });

    test('negative dimensions throw assertion errors', () {
      expect(
        () => DenseTable<int>.filled(-1, 2, 0),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => DenseTable<int>.filled(2, -1, 0),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => DenseTable<int>.generate(-1, 2, (r, c) => 0),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => DenseTable<int>.generate(2, -1, (r, c) => 0),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('Float64Table', () {
    test('.filled constructor', () {
      final table = Float64Table.filled(2, 3, 1.5);
      expect(table.rows, 2);
      expect(table.columns, 3);
      expect(table.get(0, 0), 1.5);
      expect(table.get(1, 2), 1.5);
    });

    test('.generate constructor', () {
      final table = Float64Table.generate(2, 2, (row, col) => row + col + 0.5);
      expect(table.get(0, 0), 0.5);
      expect(table.get(0, 1), 1.5);
      expect(table.get(1, 0), 1.5);
      expect(table.get(1, 1), 2.5);
    });

    test('get and set', () {
      final table = Float64Table.filled(2, 2, 0.0);
      table.set(1, 1, 42.5);
      expect(table.get(1, 1), 42.5);
      expect(table.get(0, 0), 0.0);
    });

    test('bounds checks', () {
      final table = Float64Table.filled(2, 2, 0.0);
      expect(() => table.get(-1, 0), throwsRangeError);
      expect(() => table.get(2, 0), throwsRangeError);
      expect(() => table.get(0, -1), throwsRangeError);
      expect(() => table.get(0, 2), throwsRangeError);

      expect(() => table.set(-1, 0, 1.0), throwsRangeError);
      expect(() => table.set(2, 0, 1.0), throwsRangeError);
      expect(() => table.set(0, -1, 1.0), throwsRangeError);
      expect(() => table.set(0, 2, 1.0), throwsRangeError);
    });

    test('empty table bounds checks', () {
      final table = Float64Table.filled(0, 0, 0.0);
      expect(() => table.get(0, 0), throwsRangeError);
      expect(() => table.set(0, 0, 1.0), throwsRangeError);

      final tableRow0 = Float64Table.filled(0, 2, 0.0);
      expect(() => tableRow0.get(0, 0), throwsRangeError);
      expect(() => tableRow0.set(0, 0, 1.0), throwsRangeError);

      final tableCol0 = Float64Table.filled(2, 0, 0.0);
      expect(() => tableCol0.get(0, 0), throwsRangeError);
      expect(() => tableCol0.set(0, 0, 1.0), throwsRangeError);
    });

    test('negative dimensions throw assertion errors', () {
      expect(
        () => Float64Table.filled(-1, 2, 0.0),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => Float64Table.filled(2, -1, 0.0),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => Float64Table.generate(-1, 2, (r, c) => 0.0),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => Float64Table.generate(2, -1, (r, c) => 0.0),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('Int32Table', () {
    test('.filled constructor', () {
      final table = Int32Table.filled(2, 3, 5);
      expect(table.rows, 2);
      expect(table.columns, 3);
      expect(table.get(0, 0), 5);
      expect(table.get(1, 2), 5);
    });

    test('.generate constructor', () {
      final table = Int32Table.generate(2, 2, (row, col) => row + col + 1);
      expect(table.get(0, 0), 1);
      expect(table.get(0, 1), 2);
      expect(table.get(1, 0), 2);
      expect(table.get(1, 1), 3);
    });

    test('get and set', () {
      final table = Int32Table.filled(2, 2, 0);
      table.set(1, 1, 42);
      expect(table.get(1, 1), 42);
      expect(table.get(0, 0), 0);
    });

    test('bounds checks', () {
      final table = Int32Table.filled(2, 2, 0);
      expect(() => table.get(-1, 0), throwsRangeError);
      expect(() => table.get(2, 0), throwsRangeError);
      expect(() => table.get(0, -1), throwsRangeError);
      expect(() => table.get(0, 2), throwsRangeError);

      expect(() => table.set(-1, 0, 1), throwsRangeError);
      expect(() => table.set(2, 0, 1), throwsRangeError);
      expect(() => table.set(0, -1, 1), throwsRangeError);
      expect(() => table.set(0, 2, 1), throwsRangeError);
    });

    test('empty table bounds checks', () {
      final table = Int32Table.filled(0, 0, 0);
      expect(() => table.get(0, 0), throwsRangeError);
      expect(() => table.set(0, 0, 1), throwsRangeError);

      final tableRow0 = Int32Table.filled(0, 2, 0);
      expect(() => tableRow0.get(0, 0), throwsRangeError);
      expect(() => tableRow0.set(0, 0, 1), throwsRangeError);

      final tableCol0 = Int32Table.filled(2, 0, 0);
      expect(() => tableCol0.get(0, 0), throwsRangeError);
      expect(() => tableCol0.set(0, 0, 1), throwsRangeError);
    });

    test('negative dimensions throw assertion errors', () {
      expect(() => Int32Table.filled(-1, 2, 0), throwsA(isA<AssertionError>()));
      expect(() => Int32Table.filled(2, -1, 0), throwsA(isA<AssertionError>()));
      expect(
        () => Int32Table.generate(-1, 2, (r, c) => 0),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => Int32Table.generate(2, -1, (r, c) => 0),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
