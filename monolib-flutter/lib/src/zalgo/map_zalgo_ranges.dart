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
      case 1 when isZalgoEncodableCodeUnit(codeUnit):
      case 0 when isZalgoEncodableCodeUnit(codeUnit):
        isZalgoIndex = 1;
      case 1:
      case 0:
        isZalgoIndex = 0;
      case _ when isZalgoDecodableCodeUnit(codeUnit):
        isZalgoIndex++;
      default:
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
