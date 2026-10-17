/// Core extensions for the Dart `int` type.
library;

/// An architectural extension on the core [int] type that provides
/// domain-specific utilities, such as type-safe index conversion and
/// extended base-encoding for URL-safe identifiers.
extension OnInt on int {
  /// Converts a standard `-1` "not found" index into a type-safe `null`.
  ///
  /// In Dart, many native `List` or `String` search methods (like `indexOf`
  /// or `indexWhere`) return `-1` to indicate a missing element. This getter
  /// transforms that sentinel value into an idiomatic `null`, allowing consumers
  /// to safely chain null-aware operators (`?.`, `??`) instead of writing manual
  /// imperative branch checks (`if (index != -1)`).
  ///
  /// For example, in the repository's CLI parsing architecture, this is used
  /// within `Flag.findAndRemoveFlag` to safely process argument list indices.
  ///
  /// ```dart
  /// final args = ['run', '--verbose'];
  /// final index = args.indexOf('--missing').asNullableIndex;
  ///
  /// // Safely handle the missing index without an explicit -1 check
  /// final value = index != null ? args[index] : null;
  /// ```
  int? get asNullableIndex => this == -1 ? null : this;

  /// Converts this integer to a string representation in the given [radix].
  ///
  /// This serves as an architectural enhancement over the native [int.toRadixString]
  /// method. While the native method is artificially limited to base-36 (0-9, a-z),
  /// [toExtendedRadixString] supports up to base-62 encoding (0-9, a-z, A-Z), which
  /// is critical for generating compact, URL-safe alphanumeric identifiers without
  /// relying on external cryptographic dependencies.
  ///
  /// The [radix] must be an integer between 2 and 62, inclusive. If [radix] falls
  /// outside this range, a [RangeError] is explicitly thrown.
  ///
  /// For radixes between 2 and 36, it directly delegates to [int.toRadixString] to
  /// ensure identical behavior, using lowercase letters `a`-`z` for digits 10
  /// through 35. For radixes between 37 and 62, it incorporates uppercase letters
  /// `A`-`Z` for digits 36 through 61.
  ///
  /// ```dart
  /// // Standard base-16 (hexadecimal) encoding
  /// final hex = 255.toExtendedRadixString(16); // 'ff'
  ///
  /// // Extended base-62 encoding for compact IDs
  /// final id = 123456789.toExtendedRadixString(62); // '8M0kX'
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
