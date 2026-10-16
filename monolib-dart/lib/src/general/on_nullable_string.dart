/// An architectural utility extension on nullable strings that normalizes
/// string absence across system boundaries (such as JSON payloads, CLI arguments,
/// environment variables, or form inputs).
///
/// In many serialization and input domains, the semantic difference between an
/// explicitly null value and an empty string (`""`) is negligible. This extension
/// provides methods to unify these states into a canonical Dart `null`, unlocking
/// the ability to safely leverage native null-aware operators (like `??` and `?.`)
/// instead of writing verbose manual checks (`str != null && str.isNotEmpty`).
extension OnNullableString on String? {
  /// Collapses an empty string into a structural `null`.
  ///
  /// This method serves as a sanitization gateway for external text inputs where
  /// empty strings should be treated as functionally absent. By returning `null`
  /// when the string is either `null` or `''`, it allows subsequent logic to
  /// easily provide fallbacks using the `??` operator.
  ///
  /// Returns `null` if the string is inherently `null` or exactly `""`.
  /// Otherwise, it returns the original string.
  ///
  /// Example:
  /// ```dart
  /// // Sanitizing a loosely typed JSON map where missing keys might be empty strings
  /// final rawTitle = json['title'] as String?;
  /// final title = rawTitle.emptyToNull() ?? 'Default Title';
  ///
  /// // Normalizing CLI flag inputs
  /// final input = flagValue.emptyToNull();
  /// if (input == null) {
  ///   throw ArgumentError('Flag value cannot be empty');
  /// }
  /// ```
  String? emptyToNull() => switch (this) {
        null || '' => null,
        _ => this,
      };
}
