/// Extension on [bool] that supports multi-field comparator chains.
///
/// Since [bool] does not implement [Comparable] in Dart, this extension
/// provides a way to chain boolean comparisons with fallback comparators.
extension OnBool on bool {
  /// Compares this boolean with [other], returning `null` when they are equal.
  ///
  /// Returning `null` instead of `0` on equality allows chaining fallback
  /// comparisons with the `??` operator in multi-field `sort` callbacks.
  ///
  /// When the values differ, `true` is considered greater than `false` (so
  /// `false` appears before `true` in ascending order).
  ///
  /// Example:
  /// ```dart
  /// items.sort((a, b) {
  ///   return a.isPinned.compareChain(b.isPinned) ??
  ///       a.timestamp.compareTo(b.timestamp);
  /// });
  /// ```
  int? compareChain(bool other) {
    if (this == other) return null;
    return this ? 1 : -1;
  }
}
