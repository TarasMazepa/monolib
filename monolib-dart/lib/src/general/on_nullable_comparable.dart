/// Extension on nullable [Comparable] values that provides null-safe
/// comparison.
///
/// Treats `null` as less than any non-null value so nullable fields can be
/// compared directly in `sort` callbacks without manual null checks.
///
/// Example:
/// ```dart
/// final list = <int?>[3, null, 1, 2];
/// list.sort((a, b) => a.compare(b));
/// // [null, 1, 2, 3]
/// ```
extension OnNullableComparable<T> on Comparable<T>? {
  /// Compares this nullable value with [other], treating `null` as less than
  /// any non-null value.
  ///
  /// - Returns `0` if both `this` and [other] are `null`.
  /// - Returns `-1` if `this` is `null` and [other] is non-null.
  /// - Returns `1` if `this` is non-null and [other] is `null`.
  /// - Returns `this!.compareTo(other)` if both are non-null.
  ///
  /// Example:
  /// ```dart
  /// final list = <int?>[3, null, 1, 2];
  /// list.sort((a, b) => a.compare(b)); // [null, 1, 2, 3]
  /// ```
  int compare(T? other) => switch ((this, other)) {
        (final a?, final b?) => a.compareTo(b),
        (null, null) => 0,
        (null, _) => -1,
        (_, null) => 1,
      };
}
