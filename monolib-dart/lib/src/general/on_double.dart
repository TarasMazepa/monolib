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

/// Provides utility extensions on [double] values.
extension OnDouble on double {
  /// Converts a [double] value between `0.0` and `1.0` into a
  /// five-moon rating string representation.
  ///
  /// The value is scaled to map to one of 21 possible states, ranging from zero
  /// full moons to five full moons, with partial moon phases representing
  /// fractional amounts.
  ///
  /// Throws an [ArgumentError] if the value is less than `0.0` or greater than `1.0`.
  ///
  /// ```dart
  /// print(0.0.toFiveMoonRating()); // 🌑🌑🌑🌑🌑
  /// print(0.5.toFiveMoonRating()); // 🌕🌕🌗🌑🌑
  /// print(1.0.toFiveMoonRating()); // 🌕🌕🌕🌕🌕
  /// ```
  String toFiveMoonRating() {
    if (this < 0.0 || this > 1.0) {
      throw ArgumentError.value(
          this, 'value', 'Must be between 0.0 and 1.0 inclusive.');
    }
    return _fiveMoonRatingMoons[(this * _fiveMoonRatingMoons.length)
        .floor()
        .clamp(0, _fiveMoonRatingMoons.length - 1)];
  }
}
