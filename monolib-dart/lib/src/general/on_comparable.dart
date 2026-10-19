/// Extension on [Comparable] that supports multi-field comparator chains.
///
/// Converts the `0` equality result of [Comparable.compareTo] into `null` so
/// that multiple comparisons can be chained using the null-coalescing operator
/// (`??`).
extension OnComparable<T extends Comparable<dynamic>> on T {
  /// Compares this value with [other], returning `null` when they are equal.
  ///
  /// Delegates to [Comparable.compareTo] and returns `null` instead of `0` when
  /// both values are equal, allowing fallback comparisons to be chained with
  /// the `??` operator.
  ///
  /// Example:
  /// ```dart
  /// people.sort((a, b) {
  ///   return a.lastName.compareChain(b.lastName) ??
  ///       a.firstName.compareChain(b.firstName) ??
  ///       a.age.compareTo(b.age);
  /// });
  /// ```
  int? compareChain(T other) {
    final result = compareTo(other);
    return result == 0 ? null : result;
  }
}
