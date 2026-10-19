const _fiveMoonRatingMoons = [
  '🌑🌑🌑🌑🌑',
  '🌘🌑🌑🌑🌑',
  '🌗🌑🌑🌑🌑',
  '🌖🌑🌑🌑🌑',
  '🌕🌑🌑🌑🌑',
  '🌕🌘🌑🌑🌑',
  '🌕🌗🌑🌑🌑',
  '🌕🌖🌑🌑🌑',
  '🌕🌕🌑🌑🌑',
  '🌕🌕🌘🌑🌑',
  '🌕🌕🌗🌑🌑',
  '🌕🌕🌖🌑🌑',
  '🌕🌕🌕🌑🌑',
  '🌕🌕🌕🌘🌑',
  '🌕🌕🌕🌗🌑',
  '🌕🌕🌕🌖🌑',
  '🌕🌕🌕🌕🌑',
  '🌕🌕🌕🌕🌘',
  '🌕🌕🌕🌕🌗',
  '🌕🌕🌕🌕🌖',
  '🌕🌕🌕🌕🌕',
];

/// Extension on [double] that formats values as five-moon rating strings.
extension OnDouble on double {
  /// Converts this [double] in the range `0.0` to `1.0` into a five-moon rating
  /// string.
  ///
  /// Scales the value across 21 states from zero full moons (`🌑🌑🌑🌑🌑`) to
  /// five full moons (`🌕🌕🌕🌕🌕`), using quarter-moon phases for fractional
  /// steps.
  ///
  /// Throws an [ArgumentError] if this value is less than `0.0` or greater than
  /// `1.0`.
  ///
  /// Example:
  /// ```dart
  /// print(0.0.toFiveMoonRating()); // 🌑🌑🌑🌑🌑
  /// print(0.5.toFiveMoonRating()); // 🌕🌕🌗🌑🌑
  /// print(1.0.toFiveMoonRating()); // 🌕🌕🌕🌕🌕
  /// ```
  String toFiveMoonRating() {
    if (this < 0.0 || this > 1.0) {
      throw ArgumentError.value(
        this,
        'value',
        'Must be between 0.0 and 1.0 inclusive.',
      );
    }
    return _fiveMoonRatingMoons[(this * _fiveMoonRatingMoons.length)
        .floor()
        .clamp(0, _fiveMoonRatingMoons.length - 1)];
  }
}
