/// Utilities for performing null-safe operations on [Comparable] values.
library;

/// An architectural utility providing null-safe comparison for nullable [Comparable] types.
///
/// In data-processing and UI layers (such as sorting lists or rendering data tables),
/// domain models frequently contain nullable properties. Dart's standard [Comparable.compareTo]
/// cannot be invoked on a null receiver and often does not accept null arguments.
///
/// [OnNullableComparable] safely lifts the comparison into the nullable domain.
/// It enforces a consistent sorting behavior where `null` is considered less than
/// any non-null value, bypassing manual null-checking boilerplate in comparator functions.
///
/// Example:
/// ```dart
/// final list = [3, null, 1, 2];
/// list.sort((a, b) => a.compare(b));
/// // Result: [null, 1, 2, 3]
/// ```
extension OnNullableComparable<T> on Comparable<T>? {
  /// Compares this nullable value to [other], treating `null` as the smallest possible value.
  ///
  /// This method uses switch pattern matching to safely handle all nullability combinations
  /// without throwing exceptions. It eliminates imperative `if` branching when writing
  /// multi-field sorting comparators.
  ///
  /// - Returns `0` if both `this` and [other] are `null`.
  /// - Returns `-1` if `this` is `null` and [other] is not.
  /// - Returns `1` if `this` is not `null` and [other] is `null`.
  /// - Returns the result of `this.compareTo(other)` if both are non-null.
  ///
  /// The [other] parameter represents the nullable value to compare against `this`.
  int compare(T? other) => switch ((this, other)) {
        (final a?, final b?) => a.compareTo(b),
        (null, null) => 0,
        (null, _) => -1,
        (_, null) => 1,
      };
}
