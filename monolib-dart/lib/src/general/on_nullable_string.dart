/// Extension on nullable [String]s that normalizes empty strings to `null` and provides empty checks.
extension OnNullableString on String? {
  /// Returns `null` if this string is `null` or empty (`''`), or this string
  /// otherwise.
  ///
  /// Allows empty strings to be handled with null-aware operators (`??`, `?.`)
  /// alongside `null` values.
  ///
  /// Example:
  /// ```dart
  /// final rawTitle = json['title'] as String?;
  /// final title = rawTitle.emptyToNull() ?? 'Default Title';
  /// ```
  String? emptyToNull() => switch (this) {
        null || '' => null,
        _ => this,
      };

  /// Returns `true` if this string is `null` or empty.
  bool get isNullOrEmpty => this?.isEmpty ?? true;

  /// Returns `true` if this string is not `null` and not empty.
  bool get isNotNullNorEmpty => this?.isNotEmpty ?? false;
}
