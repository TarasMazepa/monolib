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
  String toFiveMoonRating() {
    return _fiveMoonRatingMoons[(this * _fiveMoonRatingMoons.length)
        .floor()
        .clamp(0, _fiveMoonRatingMoons.length - 1)];
  }
}
