import 'package:monolib_dart/monolib_dart.dart';
import 'package:test/test.dart';

void main() {
  group('OnString', () {
    test('ensureEndsWithADot', () {
      expect(''.ensureEndsWithADot(), '.');
      expect('hello'.ensureEndsWithADot(), 'hello.');
      expect('hello.'.ensureEndsWithADot(), 'hello.');
    });

    test('removeEnclosingQuotationMarks', () {
      expect('""'.removeEnclosingQuotationMarks(), '');
      expect('"hello"'.removeEnclosingQuotationMarks(), 'hello');
      expect('"hello'.removeEnclosingQuotationMarks(), '"hello');
      expect('hello"'.removeEnclosingQuotationMarks(), 'hello"');
      expect('hello'.removeEnclosingQuotationMarks(), 'hello');
      expect(''.removeEnclosingQuotationMarks(), '');
    });
  });
}
