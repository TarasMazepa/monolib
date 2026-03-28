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

extension OnDouble on double {
  double discardedByFloor() => this - floorToDouble();

  String toFiveMoonRating() {
    return _fiveMoonRatingMoons[(this * _fiveMoonRatingMoons.length)
        .floor()
        .clamp(0, _fiveMoonRatingMoons.length - 1)];
  }
}
