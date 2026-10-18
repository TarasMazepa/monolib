import 'package:monolib_dart/fluent_json.dart';

/// Extension on [String] that parses JSON strings directly into [FluentJson]
/// instances.
extension OnString on String {
  /// Parses this [String] as JSON and wraps the decoded value in a root
  /// [FluentJson] instance via [FluentJson.decode].
  ///
  /// Uses `jsonDecode` from `dart:convert` to decode the string and initializes
  /// the breadcrumb trail for path-tracked traversal and error reporting.
  ///
  /// Throws a [FormatException] if the string is not valid JSON.
  ///
  /// Example:
  /// ```dart
  /// final rawJson = '{"user": {"name": "Alice", "age": 30}}';
  /// final userName = rawJson.parseAsFluentJson()['user']['name'].unbox<String>();
  /// print(userName); // Alice
  /// ```
  FluentJson parseAsFluentJson() => FluentJson.decode(this);
}
