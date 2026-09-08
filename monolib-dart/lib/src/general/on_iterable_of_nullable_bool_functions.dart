extension OnIterableOfNullableBoolFunctions<T> on Iterable<bool Function(T)?> {
  /// Combines nullable predicates into a single predicate that requires all to return `true`.
  ///
  /// Returns `null` if the iterable contains no non-null predicates.
  bool Function(T)? get combinedEvery =>
      switch (nonNulls.toList(growable: false)) {
        [] => null,
        [final p] => p,
        [final p1, final p2] => (x) => p1(x) && p2(x),
        [final p1, final p2, final p3] => (x) => p1(x) && p2(x) && p3(x),
        [final p1, final p2, final p3, final p4] =>
          (x) => p1(x) && p2(x) && p3(x) && p4(x),
        final ps => (x) => ps.every((p) => p(x)),
      };

  /// Combines nullable predicates into a single predicate that requires at least one to return `true`.
  ///
  /// Returns `null` if the iterable contains no non-null predicates.
  bool Function(T)? get combinedAny =>
      switch (nonNulls.toList(growable: false)) {
        [] => null,
        [final p] => p,
        [final p1, final p2] => (x) => p1(x) || p2(x),
        [final p1, final p2, final p3] => (x) => p1(x) || p2(x) || p3(x),
        [final p1, final p2, final p3, final p4] =>
          (x) => p1(x) || p2(x) || p3(x) || p4(x),
        final ps => (x) => ps.any((p) => p(x)),
      };
}
