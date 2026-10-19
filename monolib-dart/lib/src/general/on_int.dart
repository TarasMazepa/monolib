/// Extension on [int] that provides nullable index conversion and extended
/// radix formatting.
extension OnInt on int {
  /// Returns `null` if this integer is `-1`, or this integer otherwise.
  ///
  /// Converts the `-1` sentinel returned by search methods such as
  /// [List.indexOf] or [String.indexOf] into `null` for use with null-aware
  /// operators (`?.`, `??`).
  ///
  /// Example:
  /// ```dart
  /// final args = ['run', '--verbose'];
  /// final index = args.indexOf('--missing').asNullableIndex;
  /// final value = index != null ? args[index] : null;
  /// ```
  int? get asNullableIndex => this == -1 ? null : this;

  /// Converts this integer to a string representation in the given [radix].
  ///
  /// Extends [int.toRadixString] to support radixes from `2` through `62`:
  /// - Radixes `2` to `36` use digits `0`-`9` and lowercase letters `a`-`z`.
  /// - Radixes `37` to `62` additionally use uppercase letters `A`-`Z` for
  ///   digit values `36` through `61`.
  ///
  /// Throws a [RangeError] if [radix] is outside the inclusive range
  /// `[2, 62]`.
  ///
  /// Example:
  /// ```dart
  /// final hex = 255.toExtendedRadixString(16); // 'ff'
  /// final base62 = 123456789.toExtendedRadixString(62); // '8M0kX'
  /// ```
  String toExtendedRadixString(int radix) {
    if (radix < 2 || radix > 62) {
      throw RangeError.range(radix, 2, 62, 'radix');
    }

    if (radix <= 36) {
      return toRadixString(radix);
    }

    if (this == 0) {
      return '0';
    }

    const chars =
        '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final result = <String>[];

    // Use negative values to avoid overflow for int.min
    var value = this;
    final isNegative = value < 0;
    if (!isNegative) {
      value = -value;
    }

    while (value < 0) {
      result.add(chars[-(value.remainder(radix))]);
      value ~/= radix;
    }

    if (isNegative) {
      result.add('-');
    }

    return result.reversed.join();
  }
}
