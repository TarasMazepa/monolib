/// Provides an extension to natively parse JSON strings into [FluentJson] objects.
library;

import 'package:monolib_dart/fluent_json.dart';

/// Provides a concise, chainable API to parse JSON strings directly into
/// [FluentJson] objects.
///
/// This extension simplifies the initial entry point of a JSON parsing pipeline.
/// Instead of manually importing [dart:convert] and passing the string to
/// [jsonDecode] or explicitly instantiating [FluentJson.decode](), developers
/// can seamlessly transition from a raw JSON [String] to the safe, type-checked,
/// and heavily path-tracked [FluentJson] wrapper.
///
/// This pattern encourages fluent-style programming and reduces syntactic noise
/// when dealing with string payloads from network requests or file reads.
extension OnString on String {
  /// Parses the current [String] as a JSON payload and wraps the result in
  /// a [FluentJson] instance.
  ///
  /// This method internally uses [jsonDecode] from [dart:convert] to parse
  /// the string and immediately wraps the resulting dynamic object into
  /// a [FluentJson] root object, initializing the breadcrumb trail for safe
  /// traversal and detailed error reporting.
  ///
  /// Throws a [FormatException] if the string does not contain valid JSON.
  ///
  /// ```dart
  /// final rawJson = '{"user": {"name": "Alice", "age": 30}}';
  ///
  /// // Seamlessly transition from String to strongly-typed data extraction:
  /// final userName = rawJson.parseAsFluentJson()['user']['name'].unbox<String>();
  /// print(userName); // Outputs: Alice
  /// ```
  FluentJson parseAsFluentJson() => FluentJson.decode(this);
}
