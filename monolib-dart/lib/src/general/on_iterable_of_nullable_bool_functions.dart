/// Extension on [Iterable] of nullable predicates that combines them into a
/// single predicate.
///
/// Filters out `null` elements via [NullableIterableExtensions.nonNulls] before
/// combining the remaining predicates.
extension OnIterableOfNullableBoolFunctions<T> on Iterable<bool Function(T)?> {
  /// Combines all non-null predicates in this iterable using logical AND
  /// (`&&`).
  ///
  /// The returned function evaluates its argument against each non-null
  /// predicate in order, short-circuiting and returning `false` on the first
  /// predicate that returns `false`.
  ///
  /// Returns `null` if this iterable is empty or contains only `null`
  /// elements.
  ///
  /// Example:
  /// ```dart
  /// bool Function(int)? isPositive = (x) => x > 0;
  /// bool Function(int)? optionalRule = null;
  /// bool Function(int)? isEven = (x) => x.isEven;
  ///
  /// final check = [isPositive, optionalRule, isEven].combinedEvery;
  /// print(check?.call(4)); // true
  /// ```
  bool Function(T)? get combinedEvery =>
      switch (nonNulls.toList(growable: false)) {
        [] => null,
        [final p] => p,
        [final p1, final p2] => (x) => p1(x) && p2(x),
        [final p1, final p2, final p3] => (x) => p1(x) && p2(x) && p3(x),
        [final p1, final p2, final p3, final p4] => (x) =>
            p1(x) && p2(x) && p3(x) && p4(x),
        final ps => (x) => ps.every((p) => p(x)),
      };

  /// Combines all non-null predicates in this iterable using logical OR (`||`).
  ///
  /// The returned function evaluates its argument against each non-null
  /// predicate in order, short-circuiting and returning `true` on the first
  /// predicate that returns `true`.
  ///
  /// Returns `null` if this iterable is empty or contains only `null`
  /// elements.
  ///
  /// Example:
  /// ```dart
  /// bool Function(String)? isError = (s) => s == 'ERROR';
  /// bool Function(String)? optionalRule = null;
  /// bool Function(String)? isFatal = (s) => s == 'FATAL';
  ///
  /// final shouldAlert = [isError, optionalRule, isFatal].combinedAny;
  /// print(shouldAlert?.call('FATAL')); // true
  /// ```
  bool Function(T)? get combinedAny =>
      switch (nonNulls.toList(growable: false)) {
        [] => null,
        [final p] => p,
        [final p1, final p2] => (x) => p1(x) || p2(x),
        [final p1, final p2, final p3] => (x) => p1(x) || p2(x) || p3(x),
        [final p1, final p2, final p3, final p4] => (x) =>
            p1(x) || p2(x) || p3(x) || p4(x),
        final ps => (x) => ps.any((p) => p(x)),
      };
}
