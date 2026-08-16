import 'package:test/test.dart';
import 'package:monolib_dart/src/general/on_list.dart';

void main() {
  group('joinWith', () {
    test(
      'default behavior - includes prefix and suffix when ifEmpty not provided',
      () {
        expect(<int>[].joinWith(prefix: '[', suffix: ']'), '[]');
      },
    );

    test('with ifEmpty callback provided', () {
      expect(<int>[].joinWith(prefix: '[', suffix: ']', ifEmpty: () => ''), '');
    });

    test('with items', () {
      expect(
        [
          1,
          2,
          3,
        ].joinWith(prefix: '[', delimiter: ',', suffix: ']', map: (e) => '$e'),
        '[1,2,3]',
      );
    });
  });
}
