import 'package:monolib_dart/fluent_json.dart';

/// Extension methods for [FluentJson] to streamline type casting and parsing
/// of common core Dart types not strictly covered by native JSON decoding.
///
/// This extension provides targeted helpers that unbox and transform primitive
/// JSON strings directly into rich Dart types (like `DateTime`), reducing
/// boilerplate across the project.
extension OnFluentJson on FluentJson {
  /// Unboxes the current node's value as an ISO-8601 string and parses it into
  /// a Dart [DateTime] object.
  ///
  /// This internally calls [unbox] to verify that the value is a string, and
  /// then relies on [DateTime.parse]. If the value is not a string, or if it
  /// does not conform to the expected date format, an exception is thrown
  /// detailing the JSON path.
  ///
  /// ### Example
  /// ```dart
  /// final json = FluentJson.decode('{"createdAt": "2023-10-01T12:00:00Z"}');
  /// final time = json['createdAt'].asDateTime; // Returns a DateTime instance
  /// ```
  DateTime get asDateTime => DateTime.parse(unbox<String>());
}
