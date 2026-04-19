import 'dart:ui';
import 'package:monolib_flutter/monolib_flutter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monolib_dart/monolib_dart.dart';

void main() {
  group('ZalgoTextRange and mapZalgoRanges', () {
    test('ZalgoTextRange properties', () {
      const range = ZalgoTextRange(start: 0, end: 5, isZalgo: true);
      expect(range.start, 0);
      expect(range.end, 5);
      expect(range.isZalgo, isTrue);

      const collapsed = ZalgoTextRange.collapsed(3);
      expect(collapsed.start, 3);
      expect(collapsed.end, 3);
      expect(collapsed.isZalgo, isFalse);
    });

    test('ZalgoTextRange decodedTextInside', () {
      final originalText = 'Hello';
      final encodedText = zalgoEncode(originalText);
      final text = 'abc' + encodedText + 'def';

      final zalgoRange =
          ZalgoTextRange(start: 3, end: 3 + encodedText.length, isZalgo: true);
      expect(zalgoRange.decodedTextInside(text), originalText);

      final normalRange = ZalgoTextRange(start: 0, end: 3, isZalgo: false);
      expect(normalRange.decodedTextInside(text), 'abc');
    });

    test('ZalgoTextRange equality', () {
      expect(ZalgoTextRange(start: 1, end: 2, isZalgo: true),
          equals(ZalgoTextRange(start: 1, end: 2, isZalgo: true)));
      expect(ZalgoTextRange(start: 1, end: 2, isZalgo: true),
          isNot(equals(ZalgoTextRange(start: 1, end: 2, isZalgo: false))));
    });

    test('mapZalgoRanges parses plain text', () {
      final text = 'Hello world';
      final ranges = mapZalgoRanges(text);
      expect(ranges, hasLength(1));
      expect(ranges.first,
          equals(ZalgoTextRange(start: 0, end: 11, isZalgo: false)));
    });

    test('mapZalgoRanges parses mixed text', () {
      final original = 'Zalgo';
      final encoded = zalgoEncode(original);
      final text = 'abc' + encoded + 'def';

      final ranges = mapZalgoRanges(text);
      expect(ranges, hasLength(3));

      expect(
          ranges[0], equals(ZalgoTextRange(start: 0, end: 3, isZalgo: false)));
      expect(
          ranges[1],
          equals(ZalgoTextRange(
              start: 3, end: 3 + encoded.length, isZalgo: true)));
      expect(
          ranges[2],
          equals(ZalgoTextRange(
              start: 3 + encoded.length, end: text.length, isZalgo: false)));
    });
  });
}
