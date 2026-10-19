const _encodableLeft = 32;
const _encodableRight = 126;
const _decodableLeft = 0x300;
const _decodableRight = 0x300 + _encodableRight - _encodableLeft;

/// Checks whether [codeUnit] can be encoded as a Zalgo combining modifier.
///
/// Valid encodable code units are standard printable ASCII characters in the
/// inclusive range `[32, 126]` (from space to tilde).
///
/// See also:
/// * [isZalgoDecodableCodeUnit], which checks the reverse mapping.
/// * [assertZalgoEncodableCodeUnit], which throws when this returns `false`.
/// * [zalgoEncode], which encodes a string using this range.
bool isZalgoEncodableCodeUnit(int codeUnit) {
  return _encodableLeft <= codeUnit && codeUnit <= _encodableRight;
}

/// Checks whether [codeUnit] is a Zalgo combining modifier that can be decoded
/// back into a printable ASCII character.
///
/// Valid decodable code units fall within the Unicode combining diacritical
/// marks block starting at `U+0300` (`[0x300, 0x35E]`).
///
/// See also:
/// * [isZalgoEncodableCodeUnit], which checks the forward mapping.
/// * [assertZalgoDecodableCodeUnit], which throws when this returns `false`.
/// * [zalgoDecodeSingle], which decodes a Zalgo grapheme cluster.
bool isZalgoDecodableCodeUnit(int codeUnit) {
  return _decodableLeft <= codeUnit && codeUnit <= _decodableRight;
}

/// Validates that [codeUnit] can be Zalgo-encoded and returns it unchanged.
///
/// Returns [codeUnit] if [isZalgoEncodableCodeUnit] is `true`.
///
/// Throws an [Exception] if [codeUnit] is outside the printable ASCII range
/// `[32, 126]`.
int assertZalgoEncodableCodeUnit(int codeUnit) {
  if (isZalgoEncodableCodeUnit(codeUnit)) return codeUnit;
  throw Exception(
    "Can't encode '${String.fromCharCode(codeUnit)}' ($codeUnit) as it is outside of [$_encodableLeft, $_encodableRight] range.",
  );
}

/// Validates that [codeUnit] is a Zalgo combining modifier and returns it
/// unchanged.
///
/// Returns [codeUnit] if [isZalgoDecodableCodeUnit] is `true`.
///
/// Throws an [Exception] if [codeUnit] is outside the Zalgo combining mark
/// range `[0x300, 0x35E]`.
int assertZalgoDecodableCodeUnit(int codeUnit) {
  if (isZalgoDecodableCodeUnit(codeUnit)) return codeUnit;
  throw Exception(
    "Can't decode '${String.fromCharCode(codeUnit)}' ($codeUnit) as it is outside of [$_decodableLeft, $_decodableRight] range.",
  );
}

/// Decodes a single Zalgo-encoded grapheme cluster back into its original
/// ASCII string.
///
/// The [input] must start with a printable ASCII base character followed by
/// zero or more Zalgo combining modifiers. Each combining modifier is shifted
/// back to its original ASCII code unit.
///
/// Throws an [Exception] if [input] is empty, if the base character fails
/// [assertZalgoEncodableCodeUnit], or if any subsequent code unit fails
/// [assertZalgoDecodableCodeUnit].
///
/// Example:
/// ```dart
/// final encoded = zalgoEncode('Hi');
/// final decoded = zalgoDecodeSingle(encoded);
/// print(decoded); // 'Hi'
/// ```
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

/// Encodes an ASCII [input] string into a single Zalgo grapheme cluster.
///
/// Keeps the first character of [input] as the base character and converts all
/// subsequent characters into Unicode combining diacritical marks starting at
/// `U+0300`.
///
/// Throws an [Exception] if [input] is empty or if any character in [input]
/// fails [assertZalgoEncodableCodeUnit].
///
/// Example:
/// ```dart
/// final obfuscated = zalgoEncode('Secret');
/// print(obfuscated); // Outputs visually glitched text
/// ```
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
