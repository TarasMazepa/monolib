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
  /// Converts a [double] value (expected to be between `0.0` and `1.0`) into a
  /// five-moon rating string representation.
  ///
  /// The value is scaled to map to one of 21 possible states, ranging from zero
  /// full moons to five full moons, with partial moon phases representing
  /// fractional amounts.
  ///
  /// Values less than `0.0` are clamped to zero moons (`🌑🌑🌑🌑🌑`), and
  /// values greater than `1.0` are clamped to five full moons (`🌕🌕🌕🌕🌕`).
  ///
  /// ```dart
  /// print(0.0.toFiveMoonRating()); // 🌑🌑🌑🌑🌑
  /// print(0.5.toFiveMoonRating()); // 🌕🌕🌗🌑🌑
  /// print(1.0.toFiveMoonRating()); // 🌕🌕🌕🌕🌕
  /// ```
  String toFiveMoonRating() {
    return _fiveMoonRatingMoons[(this * _fiveMoonRatingMoons.length)
        .floor()
        .clamp(0, _fiveMoonRatingMoons.length - 1)];
  }
}
