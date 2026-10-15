import 'package:monolib_dart/zalgo.dart';

import 'zalgo_text_range.dart';

/// Parses the [input] string into a list of [ZalgoTextRange] objects, distinguishing between Zalgo-encoded and plain text segments.
///
/// This function scans the [input] to identify continuous ranges of characters that form Zalgo text
/// and separates them from normal text. The result is a sequential list of ranges covering the entire [input].
///
/// If the [input] is empty, it returns a single collapsed, non-Zalgo range: `[0, 0)`.
///
/// Note: Zalgo-encoded characters are parsed into individual grapheme clusters. A continuous
/// sequence of Zalgo text will be returned as multiple distinct [ZalgoTextRange] objects (one per grapheme).
///
/// Example:
/// ```dart
/// final ranges = mapZalgoRanges('Hi e̵̟̎x̴̝̾');
/// // ranges[0] represents 'Hi ' (isZalgo: false)
/// // ranges[1] represents 'e̵̟̎' (isZalgo: true)
/// // ranges[2] represents 'x̴̝̾' (isZalgo: true)
/// ```
List<ZalgoTextRange> mapZalgoRanges(String input) {
  final result = <ZalgoTextRange>[];
  int left = 0;
  int index = 0;
  int isZalgoIndex = 0;
  void reportZalgoRange() {
    final zalgoLeft = index - isZalgoIndex;
    if (zalgoLeft != left) {
      result.add(ZalgoTextRange(start: left, end: zalgoLeft, isZalgo: false));
    }
    result.add(ZalgoTextRange(start: zalgoLeft, end: index, isZalgo: true));
    left = index;
  }

  while (index < input.length) {
    final codeUnit = input.codeUnits[index];
    switch (isZalgoIndex) {
      case 1 when isZalgoDecodableCodeUnit(codeUnit):
        isZalgoIndex = 2;
      case 0 when isZalgoEncodableCodeUnit(codeUnit):
        isZalgoIndex = 1;
      case 1:
        // We had a base char (1), but the current char is NOT a decodable modifier.
        // Thus, the previous char was just plain text, not a Zalgo base.
        // But if the current char is an encodable base, we start a new potential Zalgo.
        isZalgoIndex = isZalgoEncodableCodeUnit(codeUnit) ? 1 : 0;
      case 0:
        // Not in Zalgo at all.
        isZalgoIndex = 0;
      case _ when isZalgoDecodableCodeUnit(codeUnit):
        // We are already at 2+ (base + modifiers). The current char is a modifier.
        isZalgoIndex++;
      default:
        // We are at 2+ (we HAVE a valid Zalgo sequence), but the current char is NOT a decodable modifier.
        // Therefore, the current Zalgo sequence has ended. We must report it.
        reportZalgoRange();
        isZalgoIndex = isZalgoEncodableCodeUnit(codeUnit) ? 1 : 0;
    }
    index++;
  }
  switch (isZalgoIndex) {
    case 0:
    case 1:
      result.add(ZalgoTextRange(start: left, end: index, isZalgo: false));
    default:
      reportZalgoRange();
  }
  return result;
}
