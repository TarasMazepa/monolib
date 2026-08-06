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
  });
}
