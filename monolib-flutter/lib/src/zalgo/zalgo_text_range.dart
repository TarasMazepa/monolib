import 'dart:ui';

import 'package:monolib_dart/zalgo.dart';

/// A [TextRange] representing either a plain text segment or a single
/// Zalgo-encoded grapheme cluster.
///
/// Produced by `mapZalgoRanges`, this class pairs standard UTF-16 [start] and
/// [end] offsets with an [isZalgo] flag. Because a Zalgo grapheme cluster
/// combines a base character with one or more Unicode combining modifiers, a
/// Zalgo range spans multiple UTF-16 code units.
class ZalgoTextRange extends TextRange {
  /// Whether the bounded segment is a Zalgo-encoded grapheme cluster.
  ///
  /// If `true`, the segment consists of a base character followed by Zalgo
  /// combining modifiers and can be decoded via [decodedTextInside]. If
  /// `false`, the segment is plain text.
  final bool isZalgo;

  /// Creates a [ZalgoTextRange] with the given [start] and [end] offsets and
  /// [isZalgo] flag.
  const ZalgoTextRange({
    required super.start,
    required super.end,
    required this.isZalgo,
  });

  /// Creates a collapsed [ZalgoTextRange] at [offset] with [isZalgo] set to
  /// `false`.
  ///
  /// A collapsed range has identical [start] and [end] offsets, representing an
  /// empty substring.
  const ZalgoTextRange.collapsed(super.offset)
      : isZalgo = false,
        super.collapsed();

  /// Extracts the substring bounded by this range from [text], decoding it if
  /// [isZalgo] is `true`.
  ///
  /// Uses [TextRange.textInside] to slice [text]. When [isZalgo] is `true`,
  /// passes the slice to [zalgoDecodeSingle] to un-shift the combining
  /// modifiers back to their original ASCII characters; otherwise returns the
  /// plain substring directly.
  ///
  /// Example:
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
