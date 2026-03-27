extension OnIterableMapper<T> on Iterable<T Function(T)?> {
  T Function(T)? get combined => switch (nonNulls.toList(growable: false)) {
    [] => null,
    [final mapper] => mapper,
    [final mapper1, final mapper2] => (x) => mapper1(mapper2(x)),
    [final mapper1, final mapper2, final mapper3] => (x) => mapper1(
      mapper2(mapper3(x)),
    ),
    [final mapper1, final mapper2, final mapper3, final mapper4] =>
      (x) => mapper1(mapper2(mapper3(mapper4(x)))),
    final mappers => (x) => mappers.reversed.fold(
      x,
      (value, mapper) => mapper(value),
    ),
  };
}
