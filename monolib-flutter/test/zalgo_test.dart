import 'package:flutter_test/flutter_test.dart';
import 'package:monolib_dart/zalgo.dart';
import 'package:monolib_flutter/zalgo.dart';

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
      final text = 'abc${encodedText}def';

      final zalgoRange = ZalgoTextRange(
        start: 3,
        end: 3 + encodedText.length,
        isZalgo: true,
      );
      expect(zalgoRange.decodedTextInside(text), originalText);

      final normalRange = ZalgoTextRange(start: 0, end: 3, isZalgo: false);
      expect(normalRange.decodedTextInside(text), 'abc');
    });

    test('ZalgoTextRange equality', () {
      expect(
        ZalgoTextRange(start: 1, end: 2, isZalgo: true),
        equals(ZalgoTextRange(start: 1, end: 2, isZalgo: true)),
      );
      expect(
        ZalgoTextRange(start: 1, end: 2, isZalgo: true),
        isNot(equals(ZalgoTextRange(start: 1, end: 2, isZalgo: false))),
      );
    });

    test('mapZalgoRanges parses plain text', () {
      final text = 'Hello world';
      final ranges = mapZalgoRanges(text);
      expect(ranges, hasLength(1));
      expect(
        ranges.first,
        equals(ZalgoTextRange(start: 0, end: 11, isZalgo: false)),
      );
    });

    test('mapZalgoRanges parses mixed text into distinct graphemes', () {
      // Create a string with two distinct zalgo graphemes.
      // Note: an isolated base character (e.g. 'H') requires at least one modifier to parse as Zalgo.
      final encodedHi = zalgoEncode('Ha');
      final encodedI = zalgoEncode('ia');
      final text = 'a${encodedHi}${encodedI}b';

      final ranges = mapZalgoRanges(text);
      // 'a' (normal), 'Ha' (zalgo), 'ia' (zalgo), 'b' (normal)
      expect(ranges, hasLength(4));

      int startOffset = 0;

      // 'a'
      expect(
        ranges[0],
        equals(ZalgoTextRange(start: startOffset, end: 1, isZalgo: false)),
      );
      startOffset = 1;

      // 'Ha' encoded
      expect(
        ranges[1],
        equals(
          ZalgoTextRange(
              start: startOffset,
              end: startOffset + encodedHi.length,
              isZalgo: true),
        ),
      );
      startOffset += encodedHi.length;

      // 'ia' encoded
      expect(
        ranges[2],
        equals(
          ZalgoTextRange(
              start: startOffset,
              end: startOffset + encodedI.length,
              isZalgo: true),
        ),
      );
      startOffset += encodedI.length;

      // 'b'
      expect(
        ranges[3],
        equals(
          ZalgoTextRange(
            start: startOffset,
            end: text.length,
            isZalgo: false,
          ),
        ),
      );
    });
  });
}
