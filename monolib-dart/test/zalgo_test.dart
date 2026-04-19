import 'package:monolib_dart/monolib_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Zalgo encoding/decoding', () {
    test('isZalgoEncodableCodeUnit', () {
      expect(isZalgoEncodableCodeUnit(31), isFalse);
      expect(isZalgoEncodableCodeUnit(32), isTrue); // ' '
      expect(isZalgoEncodableCodeUnit(65), isTrue); // 'A'
      expect(isZalgoEncodableCodeUnit(126), isTrue); // '~'
      expect(isZalgoEncodableCodeUnit(127), isFalse);
    });

    test('isZalgoDecodableCodeUnit', () {
      expect(isZalgoDecodableCodeUnit(0x2FF), isFalse);
      expect(isZalgoDecodableCodeUnit(0x300), isTrue);
      expect(isZalgoDecodableCodeUnit(0x300 + 126 - 32), isTrue);
      expect(isZalgoDecodableCodeUnit(0x300 + 126 - 32 + 1), isFalse);
    });

    test('encode and decode string', () {
      const original = 'Hello World 123! ~';
      final encoded = zalgoEncode(original);

      expect(encoded, isNot(original));
      expect(encoded.length, original.length);

      final decoded = zalgoDecodeSingle(encoded);
      expect(decoded, original);
    });

    test('encode empty string throws', () {
      expect(() => zalgoEncode(''), throwsException);
    });

    test('decode empty string throws', () {
      expect(() => zalgoDecodeSingle(''), throwsException);
    });

    test('encode unencodable string throws', () {
      // outside 32-126
      expect(() => zalgoEncode('Привет'), throwsException);
      expect(() => zalgoEncode('\n'), throwsException);
    });

    test('decode undecodable string throws', () {
      // we need to create a string with one character encodable and another outside decodable range
      final encodableStart = String.fromCharCode(32);
      expect(() => zalgoDecodeSingle(encodableStart + 'a'), throwsException);
    });
  });
}
