import 'package:monolib_dart/zalgo.dart';

import 'zalgo_text_range.dart';

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
