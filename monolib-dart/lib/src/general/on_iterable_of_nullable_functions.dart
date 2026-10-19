/// Extension on [Iterable] of nullable transformation functions that composes
/// them into a single function.
///
/// Filters out `null` elements via [NullableIterableExtensions.nonNulls] before
/// composing the remaining functions.
extension OnIterableOfNullableFunctions<T> on Iterable<T Function(T)?> {
  /// Composes all non-null functions in this iterable into a single function
  /// `f(g(h(x)))`.
  ///
  /// Applies functions from right to left (the last function in the iterable is
  /// applied first to the input value, and its output is passed to the
  /// preceding function).
  ///
  /// Returns `null` if this iterable is empty or contains only `null`
  /// elements.
  ///
  /// Example:
  /// ```dart
  /// final mappers = <int Function(int)?>[
  ///   (x) => x + 1, // Runs last
  ///   null,         // Ignored
  ///   (x) => x * 2, // Runs first
  /// ];
  ///
  /// // Evaluates (5 * 2) + 1
  /// final result = mappers.combined?.call(5); // 11
  /// ```
  T Function(T)? get combined => switch (nonNulls.toList(growable: false)) {
        [] => null,
        [final mapper] => mapper,
        [final mapper1, final mapper2] => (x) => mapper1(mapper2(x)),
        [final mapper1, final mapper2, final mapper3] => (x) => mapper1(
              mapper2(mapper3(x)),
            ),
        [final mapper1, final mapper2, final mapper3, final mapper4] => (x) =>
            mapper1(mapper2(mapper3(mapper4(x)))),
        final mappers => (x) => mappers.reversed.fold(
              x,
              (value, mapper) => mapper(value),
            ),
      };
}
