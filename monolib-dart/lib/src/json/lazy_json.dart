/// Provides architectural utilities to defer JSON evaluation during serialization.
library;

/// A wrapper that delays the computation or generation of a JSON structure until
/// the exact moment it is serialized.
///
/// In asynchronous or performance-sensitive architectures, pre-computing large
/// JSON trees (like mapping deeply nested domain models to maps) can block
/// the isolate or unnecessarily consume memory if the object is ultimately
/// discarded or queued for a long time.
///
/// By wrapping the payload generation in [LazyJson], the actual execution
/// is deferred. When a standard serializer like `jsonEncode` or the repository's
/// asynchronous `jsonEncodeAsync` processes this object, it dynamically invokes
/// the [toJson] callback.
///
/// ### Example
/// ```dart
/// final payload = LazyJson(() {
///   // This expensive mapping logic runs only when jsonEncode() is called.
///   return {'timestamp': DateTime.now().toIso8601String(), 'data': 'massive'};
/// });
///
/// // Evaluation happens here
/// final jsonString = jsonEncode(payload);
/// ```
class LazyJson {
  /// The deferred computation that returns the actual JSON-serializable structure.
  ///
  /// This function is automatically invoked by native Dart encoders (such as `jsonEncode`)
  /// or asynchronous encoders (like `jsonEncodeAsync`) because they dynamically look
  /// for a `toJson` member. The result should be a standard JSON-compatible type
  /// (e.g., [Map], [List], [String], [int], or another object with a `toJson`).
  final dynamic Function() toJson;

  /// Creates a [LazyJson] that will execute [toJson] when serialized.
  const LazyJson(this.toJson);
}
