/// Provides domain-specific type conversion extensions for [FluentJson].
///
/// In the repository's data-parsing architecture, [FluentJson] acts as a
/// safe, path-tracked wrapper over dynamic JSON structures. This extension
/// supplements the base unboxing capabilities of [FluentJson] by bridging
/// raw JSON values into concrete Dart semantic objects (such as
/// [DateTime]), ensuring that parsing logic remains centralized and
/// easily accessible during JSON traversal.
library;

import 'package:monolib_dart/fluent_json.dart';

/// Extends [FluentJson] with convenient, type-safe data conversion getters.
///
/// While [FluentJson.unbox] handles primitive casting, [OnFluentJson]
/// focuses on transforming those primitives into meaningful domain types.
/// This prevents developers from having to manually unbox and parse strings
/// at every call site, keeping JSON deserialization pipelines declarative
/// and readable.
///
/// ```dart
/// final jsonStr = '{"event": "login", "timestamp": "2023-10-15T13:45:30.000Z"}';
/// final json = jsonStr.parseAsFluentJson();
///
/// // Cleanly extract and parse the ISO 8601 string into a DateTime
/// final loginTime = json['timestamp'].asDateTime;
/// ```
extension OnFluentJson on FluentJson {
  /// Unboxes the underlying JSON value as a [String] and parses it into a [DateTime].
  ///
  /// This getter extracts the current path's value via [FluentJson.unbox]
  /// and delegates to [DateTime.parse]. The unboxed string must be formatted
  /// as a valid ISO 8601 date (e.g., `"2024-05-22T14:30:00Z"`). It is widely
  /// used across the repository when consuming API payloads that encode
  /// timestamps as standard strings.
  ///
  /// Throws an [Exception] if the underlying JSON value is `null` or not
  /// a [String]. Throws a [FormatException] if the string cannot be correctly
  /// parsed into a [DateTime].
  DateTime get asDateTime => DateTime.parse(unbox<String>());
}
