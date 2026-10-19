import 'package:monolib_dart/monolib_dart.dart';
import 'package:test/test.dart';

void main() {
  group('OnNullableString', () {
    test('emptyToNull', () {
      expect(''.emptyToNull(), isNull);
      expect((null as String?).emptyToNull(), isNull);
      expect('hello'.emptyToNull(), 'hello');
      expect('   '.emptyToNull(), '   ');
    });

    test('isNullOrEmpty', () {
      String? nullString;
      expect(nullString.isNullOrEmpty, isTrue);

      String? emptyString = '';
      expect(emptyString.isNullOrEmpty, isTrue);

      String? notEmptyString = 'a';
      expect(notEmptyString.isNullOrEmpty, isFalse);
    });

    test('isNotNullNorEmpty', () {
      String? nullString;
      expect(nullString.isNotNullNorEmpty, isFalse);

      String? emptyString = '';
      expect(emptyString.isNotNullNorEmpty, isFalse);

      String? notEmptyString = 'a';
      expect(notEmptyString.isNotNullNorEmpty, isTrue);
    });
  });
}
