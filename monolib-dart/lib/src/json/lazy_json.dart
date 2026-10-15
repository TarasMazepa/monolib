/// A wrapper for deferring the serialization of an object to JSON.
///
/// In asynchronous or streamed logging environments, building a complete JSON
/// object (e.g., via `Map<String, dynamic>`) can be computationally expensive
/// and allocate unnecessary memory if the log level is ultimately ignored or
/// discarded before output.
///
/// [LazyJson] accepts a closure ([toJson]) that is only invoked when the underlying
/// data actually needs to be encoded. This inversion of control ensures that
/// complex serialization logic is skipped if the target output never consumes it.
///
/// ### Example Usage
/// ```dart
/// final logEvent = LazyJson(() => {
///   'timestamp': DateTime.now().toIso8601String(),
///   'data': expensiveComputation(),
/// });
///
/// // 'expensiveComputation' is NOT called until 'logEvent.toJson()' is explicitly invoked
/// // by an encoder or logger.
/// ```
class LazyJson {
  /// A closure that generates the underlying JSON-encodable data (typically
  /// a `Map<String, dynamic>`, `List<dynamic>`, `String`, `num`, or `bool`)
  /// when invoked.
  final dynamic Function() toJson;

  /// Constructs a [LazyJson] object using the deferred [toJson] callback.
  const LazyJson(this.toJson);
}
