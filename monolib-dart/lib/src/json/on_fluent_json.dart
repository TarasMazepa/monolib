import 'package:monolib_dart/fluent_json.dart';

/// Extension on [FluentJson] that provides type-safe conversion getters for
/// domain types.
///
/// Example:
/// ```dart
/// final jsonStr = '{"event": "login", "timestamp": "2023-10-15T13:45:30.000Z"}';
/// final json = jsonStr.parseAsFluentJson();
///
/// final loginTime = json['timestamp'].asDateTime;
/// ```
extension OnFluentJson on FluentJson {
  /// Unboxes the underlying JSON value as a [String] and parses it into a [DateTime].
  ///
  /// Extracts the current node's value via [FluentJson.unbox] and passes it to
  /// [DateTime.parse].
  ///
  /// Throws an [Exception] if the underlying JSON value is `null` or not a
  /// [String]. Throws a [FormatException] if the string is not a valid
  /// [DateTime] representation.
  DateTime get asDateTime => DateTime.parse(unbox<String>());
}
