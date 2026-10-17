/// Provides core utilities for encoding and decoding text using the Zalgo effect.
///
/// In this architecture, "Zalgo" text is utilized to visually obfuscate or creatively
/// format strings by converting standard printable ASCII characters into Unicode
/// combining diacritical marks (ranging from `U+0300` onwards). The first character
/// of a sequence remains a standard base character, while subsequent encoded characters
/// are appended as modifiers, creating a single "glitched" grapheme cluster.
///
/// This library is primarily consumed by text-parsing pipelines (such as `mapZalgoRanges`
/// and `ZalgoTextRange` in the Flutter package) to identify, split, and decode
/// these obfuscated continuous ranges back into readable text for UI components.
library;

const _encodableLeft = 32;
const _encodableRight = 126;
const _decodableLeft = 0x300;
const _decodableRight = 0x300 + _encodableRight - _encodableLeft;

/// Checks whether a given [codeUnit] can be converted into a Zalgo modifier.
///
/// Valid encodable code units are strictly standard printable ASCII characters
/// (from space `32` to tilde `126`). Characters outside this range cannot be
/// reliably mapped to the corresponding Unicode combining block.
///
/// See also:
/// * [isZalgoDecodableCodeUnit], which checks the reverse mapping.
/// * [assertZalgoEncodableCodeUnit], which enforces this check.
/// * [zalgoEncode], the primary consumer of this validation logic.
bool isZalgoEncodableCodeUnit(int codeUnit) {
  return _encodableLeft <= codeUnit && codeUnit <= _encodableRight;
}

/// Checks whether a given [codeUnit] represents a valid Zalgo modifier
/// that can be converted back into a printable ASCII character.
///
/// Valid decodable code units fall within the specific block of Unicode
/// combining diacritical marks mapped by this library, starting at `U+0300`.
///
/// See also:
/// * [isZalgoEncodableCodeUnit], which checks the reverse mapping.
/// * [assertZalgoDecodableCodeUnit], which enforces this check.
/// * [zalgoDecodeSingle], the primary consumer of this validation logic.
bool isZalgoDecodableCodeUnit(int codeUnit) {
  return _decodableLeft <= codeUnit && codeUnit <= _decodableRight;
}

/// Asserts that a [codeUnit] is valid for encoding, returning it if successful.
///
/// Acts as a strict guard in encoding pipelines to prevent malformed grapheme
/// generation by ensuring the character is supported.
///
/// Returns the given [codeUnit] unmodified if [isZalgoEncodableCodeUnit] is `true`.
/// Throws an [Exception] if the [codeUnit] falls outside the allowed printable
/// ASCII range `[32, 126]`.
///
/// See also:
/// * [zalgoEncode], which relies on this to sanitize input.
int assertZalgoEncodableCodeUnit(int codeUnit) {
  if (isZalgoEncodableCodeUnit(codeUnit)) return codeUnit;
  throw Exception(
    "Can't encode '${String.fromCharCode(codeUnit)}' ($codeUnit) as it is outside of [$_encodableLeft, $_encodableRight] range.",
  );
}

/// Asserts that a [codeUnit] is a valid Zalgo modifier, returning it if successful.
///
/// This is used internally during decoding to ensure only intended Zalgo segments
/// are un-shifted back to plain text.
///
/// Returns the given [codeUnit] unmodified if [isZalgoDecodableCodeUnit] is `true`.
/// Throws an [Exception] if the [codeUnit] is not a recognized mapped combining mark
/// falling within the block starting at `U+0300`.
///
/// See also:
/// * [zalgoDecodeSingle], which relies on this to sanitize input.
int assertZalgoDecodableCodeUnit(int codeUnit) {
  if (isZalgoDecodableCodeUnit(codeUnit)) return codeUnit;
  throw Exception(
    "Can't decode '${String.fromCharCode(codeUnit)}' ($codeUnit) as it is outside of [$_decodableLeft, $_decodableRight] range.",
  );
}

/// Decodes a single continuous Zalgo grapheme cluster back into its original text.
///
/// A valid Zalgo-encoded [input] sequence must begin with a base encodable
/// character (a printable ASCII character), followed by one or more valid
/// combining modifiers. This function un-shifts those modifiers back to their
/// original ASCII code units.
///
/// This function is typically invoked by higher-level adapters (e.g., `ZalgoTextRange.decodedTextInside`)
/// when a parsed Zalgo segment needs to be read or displayed natively.
///
/// Throws an [Exception] if [input] is empty. It also throws if the base character
/// fails [assertZalgoEncodableCodeUnit], or if subsequent modifiers fail
/// [assertZalgoDecodableCodeUnit].
///
/// Example:
/// ```dart
/// final encoded = zalgoEncode('Hi');
/// final decoded = zalgoDecodeSingle(encoded);
/// print(decoded); // Outputs: 'Hi'
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

/// Encodes a standard string into a single Zalgo grapheme cluster.
///
/// The encoding process retains the very first character of the [input] as the base
/// character, and converts all subsequent characters into Unicode combining diacritical
/// marks (starting from `U+0300`). This results in a sequence that renders visually as
/// heavily modified "glitch" text clustered around the initial character.
///
/// Throws an [Exception] if [input] is empty, or if any character in the [input]
/// fails [assertZalgoEncodableCodeUnit] (meaning it is not a standard printable ASCII character).
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
