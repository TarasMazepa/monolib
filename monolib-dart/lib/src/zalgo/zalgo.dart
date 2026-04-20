const _encodableLeft = 32;
const _encodableRight = 126;
const _decodableLeft = 0x300;
const _decodableRight = 0x300 + _encodableRight - _encodableLeft;

bool isZalgoEncodableCodeUnit(int codeUnit) {
  return _encodableLeft <= codeUnit && codeUnit <= _encodableRight;
}

bool isZalgoDecodableCodeUnit(int codeUnit) {
  return _decodableLeft <= codeUnit && codeUnit <= _decodableRight;
}

int assertZalgoEncodableCodeUnit(int codeUnit) {
  if (isZalgoEncodableCodeUnit(codeUnit)) return codeUnit;
  throw Exception(
    "Can't encode '${String.fromCharCode(codeUnit)}' ($codeUnit) as it is outside of [$_encodableLeft, $_encodableRight] range.",
  );
}

int assertZalgoDecodableCodeUnit(int codeUnit) {
  if (isZalgoDecodableCodeUnit(codeUnit)) return codeUnit;
  throw Exception(
    "Can't decode '${String.fromCharCode(codeUnit)}' ($codeUnit) as it is outside of [$_decodableLeft, $_decodableRight] range.",
  );
}

String zalgoDecodeSingle(String input) {
  final iterator = input.codeUnits.iterator;
  if (!iterator.moveNext()) {
    throw Exception("Can't zalgo decode empty string.");
  }
  final result = StringBuffer()
    ..writeCharCode(assertZalgoEncodableCodeUnit(iterator.current));
  while (iterator.moveNext()) {
    result.writeCharCode(
      assertZalgoDecodableCodeUnit(iterator.current) -
          _decodableLeft +
          _encodableLeft,
    );
  }
  return result.toString();
}

String zalgoEncode(String input) {
  final iterator = input.codeUnits.iterator;
  if (!iterator.moveNext()) {
    throw Exception("Can't zalgo encode empty string.");
  }
  int getCodeUnit() => assertZalgoEncodableCodeUnit(iterator.current);
  final result = StringBuffer()..writeCharCode(getCodeUnit());
  while (iterator.moveNext()) {
    result.writeCharCode(getCodeUnit() - _encodableLeft + _decodableLeft);
  }
  return result.toString();
}
