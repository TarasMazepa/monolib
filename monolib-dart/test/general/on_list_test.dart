import 'package:monolib_dart/src/general/on_list.dart';
import 'package:test/test.dart';

void main() {
  group('joinWith', () {
    test('default behavior - includes prefix and suffix', () {
      expect(<int>[].joinWith(prefix: '[', suffix: ']'), '[]');
    });

    test('ifEmpty provided - returns custom value', () {
      expect(
        <int>[].joinWith(prefix: '[', suffix: ']', ifEmpty: () => ''),
        '',
      );
    });

    test('with items', () {
      expect(
        [1, 2, 3].joinWith(
          prefix: '[',
          delimiter: ',',
          suffix: ']',
          map: (e) => '$e',
        ),
        '[1,2,3]',
      );
    });
  });
}
