import 'package:monolib_dart/fluent_json.dart';

/// Convenience extension on [String] to directly decode JSON strings into
/// the [FluentJson] traversal API.
///
/// This serves as an ergonomic shortcut, preventing the need to import and invoke
/// `FluentJson.decode(string)` manually. Instead, it allows a fluid, chainable
/// parsing syntax directly from string payloads, which is particularly useful
/// when handling raw HTTP responses or file contents.
extension OnString on String {
  /// Parses the current string as JSON and wraps it in a [FluentJson] instance.
  ///
  /// This delegates entirely to [FluentJson.decode], maintaining an empty initial
  /// breadcrumb path. If the string is not valid JSON, it throws a standard Dart
  /// `FormatException`.
  ///
  /// ### Example
  /// ```dart
  /// final rawPayload = '{"settings": {"dark_mode": true}}';
  ///
  /// // Fluid syntax without needing `FluentJson` explicit invocations
  /// final isDarkMode = rawPayload.parseAsFluentJson()['settings']['dark_mode'].unbox<bool>();
  /// ```
  FluentJson parseAsFluentJson() => FluentJson.decode(this);
}
