import 'dart:ui';

import 'package:monolib_dart/zalgo.dart';

class ZalgoTextRange extends TextRange {
  final bool isZalgo;

  const ZalgoTextRange({
    required super.start,
    required super.end,
    required this.isZalgo,
  });

  const ZalgoTextRange.collapsed(super.offset)
      : isZalgo = false,
        super.collapsed();

  String decodedTextInside(String text) {
    final inside = textInside(text);
    if (isZalgo) return zalgoDecodeSingle(inside);
    return inside;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;
    if (other is! ZalgoTextRange) return false;
    return start == other.start && end == other.end && isZalgo == other.isZalgo;
  }

  @override
  int get hashCode => Object.hash(isZalgo, super.hashCode);

  @override
  String toString() {
    return '${isZalgo ? 'Zalgo' : ''}[$start, $end)';
  }
}
