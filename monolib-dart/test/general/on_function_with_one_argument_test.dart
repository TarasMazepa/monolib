import 'package:monolib_dart/monolib_dart.dart';
import 'package:test/test.dart';

void main() {
  group('OnFunctionWithOneArgument', () {
    test('withAnArgument', () {
      int addOne(int x) => x + 1;
      final addOneToFive = addOne.withAnArgument(5);
      expect(addOneToFive(), 6);
    });
  });
}
