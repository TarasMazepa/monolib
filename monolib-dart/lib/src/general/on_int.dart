extension OnInt on int {
  /// Converts a standard -1 "not found" index to null.
  int? get asNullableIndex => this == -1 ? null : this;

  /// Converts this integer to a string representation in the given [radix].
  ///
  /// This is similar to [toRadixString] but allows for a radix up to 62.
  /// The [radix] must be an integer between 2 and 62, inclusive.
  ///
  /// For radixes between 2 and 36, it matches the behavior of [toRadixString],
  /// using lowercase letters `a`-`z` for digits 10 through 35.
  /// For radixes between 37 and 62, it uses uppercase letters `A`-`Z` for
  /// digits 36 through 61.
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
