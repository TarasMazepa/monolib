import 'package:monolib_dart/zalgo.dart';
import 'package:monolib_flutter/src/zalgo/zalgo_text_range.dart';

/// Parses [input] into non-overlapping [ZalgoTextRange] segments of plain text
/// and Zalgo grapheme clusters.
///
/// Scans [input]'s code units in a single pass, using
/// [isZalgoEncodableCodeUnit] to detect potential base characters and
/// [isZalgoDecodableCodeUnit] to identify subsequent combining modifiers.
///
/// If [input] is empty, returns a single collapsed, non-Zalgo range: `[0, 0)`.
///
/// Because Zalgo text is encoded at the grapheme cluster level (one base
/// character followed by combining modifiers), contiguous Zalgo clusters are
/// returned as separate [ZalgoTextRange] entries rather than merged into a
/// single range.
///
/// Example:
/// ```dart
/// final ranges = mapZalgoRanges('Hi e̵̟̎x̴̝̾');
///
/// // ranges[0] is plain text 'Hi '
/// // ranges[1] is Zalgo text 'e̵̟̎'
/// // ranges[2] is Zalgo text 'x̴̝̾'
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
