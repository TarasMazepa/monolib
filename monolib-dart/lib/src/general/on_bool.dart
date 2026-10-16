/// Provides domain-specific extensions on the native [bool] type to facilitate
/// multi-field sorting operations.
library;

/// Extensions for the native [bool] type that aid in building complex,
/// multi-field comparator chains.
///
/// Since [bool] does not natively implement [Comparable] in Dart, this extension
/// provides a standardized way to evaluate boolean sorting precedence.
extension OnBool on bool {
  /// Compares this boolean against [other] for sorting, returning `null` if they
  /// are equal. This allows for graceful chaining of fallback comparators using
  /// the `??` operator.
  ///
  /// This method is designed to be used in multi-field `sort` functions where
  /// boolean fields dictate primary or secondary sorting criteria. By returning
  /// `null` instead of `0` on equality, it avoids terminating the comparison
  /// chain prematurely.
  ///
  /// When the values differ, `true` is considered greater than `false` (meaning
  /// `false` appears before `true` in ascending sorts).
  ///
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
