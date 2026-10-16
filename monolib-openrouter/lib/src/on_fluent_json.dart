/// Domain-specific [FluentJson] extensions for OpenRouter API responses.
///
/// This library provides validation utilities to verify that raw OpenRouter
/// (or OpenAI-compatible) JSON payloads do not contain architectural-level
/// failures (such as rate limits or authentication errors) before the consumer
/// attempts to parse standard expected fields (like `choices`).
library;

import 'dart:convert';

import 'package:monolib_dart/fluent_json.dart';

/// Adapts the generic [FluentJson] utility for OpenRouter API semantics.
///
/// While [FluentJson] handles safe, dynamic traversal of JSON trees, OpenRouter
/// HTTP APIs often return a 200 OK status code alongside a payload containing a
/// top-level `"error"` object when a request fails (e.g., due to strict routing
/// failures or provider issues).
///
/// This extension allows consumers to eagerly validate the structural integrity
/// of the response, safely throwing an exception if an error is present, or
/// continuing down a fluent chain if the payload is healthy.
extension OnFluentJson on FluentJson {
  /// Asserts that the JSON payload does not contain a top-level `"error"` node.
  ///
  /// The OpenRouter API (and OpenAI specification) wraps failures in a root-level
  /// `"error"` object (e.g., `{"error": {"message": "Rate limited", ...}}`).
  /// This method proactively checks for that node using [elementAt].
  ///
  /// If the `"error"` node is found, this throws an [Exception] containing the
  /// stringified JSON of the error payload. If the node is absent, it returns
  /// `this` [FluentJson] instance, allowing for seamless method chaining during
  /// data extraction.
  ///
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
