import 'dart:convert';

import 'package:monolib_dart/fluent_json.dart';

/// Extension on [FluentJson] that validates OpenRouter API responses for
/// top-level error payloads.
///
/// OpenRouter HTTP APIs may return a `200 OK` status code with a top-level
/// `"error"` object when a request fails (for example, due to provider routing
/// errors or rate limits). This extension checks for such errors before
/// extracting fields in a fluent chain.
extension OnFluentJson on FluentJson {
  /// Asserts that the JSON payload does not contain a top-level `"error"` node.
  ///
  /// Checks for a root-level `"error"` entry (e.g.,
  /// `{"error": {"message": "Rate limited", ...}}`) using [elementAt].
  ///
  /// Throws an [Exception] containing the JSON-encoded error payload if the
  /// `"error"` node is present; otherwise returns `this` [FluentJson] instance
  /// for method chaining.
  ///
  /// Example:
  /// ```dart
  /// final responseBody = '{"error": {"message": "Invalid API key"}}';
  /// final json = FluentJson.decode(responseBody);
  ///
  /// // Throws an Exception containing the error details
  /// json.assertNoTopLevelError();
  ///
  /// // In a healthy response, it allows chained extraction:
  /// final content = FluentJson.decode('{"choices": [{"message": {"content": "Hello"}}]}')
  ///     .assertNoTopLevelError()['choices']
  ///     .unboxIterable()
  ///     .first['message']['content']
  ///     .unbox<String>();
  /// ```
  FluentJson assertNoTopLevelError() {
    if (elementAt('error') case final error?) {
      throw Exception('''Top level error

${jsonEncode(error.json)}''');
    }
    return this;
  }
}
