/// Data structures for representing parsed ranges of Zalgo text within strings.
library;

import 'dart:ui';

import 'package:monolib_dart/zalgo.dart';

/// A specialized [TextRange] that identifies whether its bounded substring is
/// plain text or a Zalgo-encoded grapheme cluster.
///
/// This class represents a single token parsed from a larger string by [mapZalgoRanges].
/// It extends [TextRange] to inherit standard start and end indices for string slicing,
/// while introducing the [isZalgo] flag to dictate how the bounded segment should
/// be handled during rendering or decoding. Because Zalgo text combines a base
/// character with multiple combining modifiers, a single [ZalgoTextRange] often covers
/// multiple UTF-16 code units (e.g., `start` to `end` spanning the entire grapheme).
class ZalgoTextRange extends TextRange {
  /// Indicates whether the bounded segment is Zalgo-encoded.
  ///
  /// If `true`, the segment is a Zalgo grapheme cluster and needs decoding
  /// to reveal the underlying base character. If `false`, the segment is
  /// standard plain text.
  final bool isZalgo;

  /// Creates a [ZalgoTextRange] specifying its [start] and [end] bounds,
  /// along with its [isZalgo] status.
  const ZalgoTextRange({
    required super.start,
    required super.end,
    required this.isZalgo,
  });

  /// Creates a collapsed [ZalgoTextRange] at a specific [offset], with [isZalgo]
  /// inherently set to `false`.
  ///
  /// A collapsed range has identical start and end offsets, representing an empty
  /// substring (e.g., when the parsed source string is entirely empty).
  const ZalgoTextRange.collapsed(super.offset)
      : isZalgo = false,
        super.collapsed();

  /// Extracts the substring bounded by this range from [text] and decodes it if
  /// it is Zalgo-encoded.
  ///
  /// This method safely delegates to [TextRange.textInside] to extract the raw
  /// bounded string. If [isZalgo] is `true`, it processes the extracted segment
  /// through [zalgoDecodeSingle] to strip combining modifiers and return the
  /// base character. If `false`, it returns the plain text unmodified.
  ///
  /// ```dart
  /// final text = 'Hi e̵̟̎x̴̝̾';
  /// final ranges = mapZalgoRanges(text);
  ///
  /// // ranges[0] is plain text 'Hi '
  /// print(ranges[0].decodedTextInside(text)); // 'Hi '
  ///
  /// // ranges[1] is Zalgo text 'e̵̟̎'
  /// print(ranges[1].decodedTextInside(text)); // 'e'
  /// ```
  String decodedTextInside(String text) {
    final inside = textInside(text);
    if (isZalgo) return zalgoDecodeSingle(inside);
    return inside;
  }

  /// Compares this [ZalgoTextRange] against [other] for equality.
  ///
  /// Two ranges are considered equal if they have the same type, identical
  /// `start` and `end` offsets, and matching [isZalgo] flags.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;
    if (other is! ZalgoTextRange) return false;
    return start == other.start && end == other.end && isZalgo == other.isZalgo;
  }

  /// Generates a hash code combining the `start`, `end`, and [isZalgo] flag.
  @override
  int get hashCode => Object.hash(isZalgo, super.hashCode);

  /// Returns a string representation of this range, prefixing the standard
  /// `[start, end)` output with 'Zalgo' if [isZalgo] is `true`.
  @override
  String toString() {
    return '${isZalgo ? 'Zalgo' : ''}[$start, $end)';
  }
}
