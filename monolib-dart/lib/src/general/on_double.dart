extension OnDouble on double {
  double discardedByFloor() => this - floorToDouble();

  String toStars() {
    const moons = [
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
    return moons[(this * moons.length).floor().clamp(0, moons.length - 1)];
  }
}
