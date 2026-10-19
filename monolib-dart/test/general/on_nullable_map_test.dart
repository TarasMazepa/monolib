import 'package:monolib_dart/src/general/on_nullable_map.dart';
import 'package:test/test.dart';

void main() {
  group('OnNullableMap', () {
    test('isNullOrEmpty', () {
      Map<String, int>? nullMap;
      expect(nullMap.isNullOrEmpty, isTrue);

      Map<String, int>? emptyMap = {};
      expect(emptyMap.isNullOrEmpty, isTrue);

      Map<String, int>? notEmptyMap = {'a': 1};
      expect(notEmptyMap.isNullOrEmpty, isFalse);
    });

    test('isNotNullNorEmpty', () {
      Map<String, int>? nullMap;
      expect(nullMap.isNotNullNorEmpty, isFalse);

      Map<String, int>? emptyMap = {};
      expect(emptyMap.isNotNullNorEmpty, isFalse);

      Map<String, int>? notEmptyMap = {'a': 1};
      expect(notEmptyMap.isNotNullNorEmpty, isTrue);
    });
  });
}
