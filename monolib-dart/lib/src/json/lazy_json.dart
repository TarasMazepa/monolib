/// A wrapper that defers computing a JSON-serializable value until it is
/// serialized.
///
/// Wrapping a computation in [LazyJson] delays evaluation until a serializer
/// such as `jsonEncode` or `jsonEncodeAsync` invokes [toJson].
///
/// Example:
/// ```dart
/// final payload = LazyJson(() {
///   // This mapping logic runs only when jsonEncode() is called.
///   return {'timestamp': DateTime.now().toIso8601String(), 'data': 'massive'};
/// });
///
/// final jsonString = jsonEncode(payload);
/// ```
class LazyJson {
  /// The deferred callback that returns the JSON-serializable value.
  ///
  /// Invoked automatically by encoders such as `jsonEncode` or
  /// `jsonEncodeAsync`.
  final dynamic Function() toJson;

  /// Creates a [LazyJson] that executes [toJson] when serialized.
  const LazyJson(this.toJson);
}
