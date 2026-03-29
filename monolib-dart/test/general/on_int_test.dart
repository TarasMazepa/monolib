import 'package:monolib_dart/src/general/on_int.dart';
import 'package:test/test.dart';

void main() {
  group('OnInt', () {
    group('asNullableIndex', () {
      test('returns null for -1', () {
        expect((-1).asNullableIndex, isNull);
      });

      test('returns the integer for other values', () {
        expect(0.asNullableIndex, equals(0));
        expect(1.asNullableIndex, equals(1));
        expect((-2).asNullableIndex, equals(-2));
      });
    });

    group('toExtendedRadixString', () {
      test('delegates to toRadixString for radix <= 36', () {
        expect(255.toExtendedRadixString(16), equals('ff'));
        expect(10.toExtendedRadixString(2), equals('1010'));
        expect((-255).toExtendedRadixString(16), equals('-ff'));
        expect(0.toExtendedRadixString(36), equals('0'));
        expect(35.toExtendedRadixString(36), equals('z'));
      });

      test('handles radix > 36 up to 62', () {
        expect(0.toExtendedRadixString(62), equals('0'));
        expect(10.toExtendedRadixString(62), equals('a'));
        expect(35.toExtendedRadixString(62), equals('z'));
        expect(36.toExtendedRadixString(62), equals('A'));
        expect(61.toExtendedRadixString(62), equals('Z'));

        expect(62.toExtendedRadixString(62), equals('10'));
        expect((62 * 62 - 1).toExtendedRadixString(62), equals('ZZ'));

        expect((-61).toExtendedRadixString(62), equals('-Z'));
        expect((-62).toExtendedRadixString(62), equals('-10'));
      });

      test('throws RangeError for invalid radix', () {
        expect(() => 10.toExtendedRadixString(1), throwsRangeError);
        expect(() => 10.toExtendedRadixString(63), throwsRangeError);
      });

      test('handles int.max and int.min correctly', () {
        // We use 36 and 62 radices
        // max 64-bit int is 9223372036854775807
        // min 64-bit int is -9223372036854775808
        const int minInt = -9223372036854775808;
        const int maxInt = 9223372036854775807;

        expect(minInt.toExtendedRadixString(36), equals('-1y2p0ij32e8e8'));
        expect(maxInt.toExtendedRadixString(36), equals('1y2p0ij32e8e7'));

        // Let's verify base 62 encoding logic correctness using BigInt
        // for int.min
        final minIntStr = minInt.toExtendedRadixString(62);
        expect(minIntStr.startsWith('-'), isTrue);

        final maxIntStr = maxInt.toExtendedRadixString(62);

        // Manual base62 computation for minInt using BigInt to verify the output
        final minBigInt = BigInt.from(minInt).abs();
        final maxBigInt = BigInt.from(maxInt);

        String bigIntToBase62(BigInt value) {
          if (value == BigInt.zero) return '0';
          const chars =
              '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
          final result = <String>[];
          var current = value;
          final radixBig = BigInt.from(62);
          while (current > BigInt.zero) {
            final remainder = (current % radixBig).toInt();
            result.add(chars[remainder]);
            current ~/= radixBig;
          }
          return result.reversed.join();
        }

        expect(minIntStr, equals('-${bigIntToBase62(minBigInt)}'));
        expect(maxIntStr, equals(bigIntToBase62(maxBigInt)));
      });
    });
  });
}
