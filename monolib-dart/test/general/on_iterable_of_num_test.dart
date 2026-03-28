import 'package:monolib_dart/monolib_dart.dart';
import 'package:test/test.dart';

void main() {
  group('OnIterableOfNum', () {
    test('operator /', () {
      final numbers = [10, 20.0, 5];
      final divided = (numbers / 2).toList();
      expect(divided, [5.0, 10.0, 2.5]);
    });
  });
}
