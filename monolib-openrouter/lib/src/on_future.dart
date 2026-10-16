import 'dart:async';

/// An architectural extension that bridges standard asynchronous [Future]s into
/// fault-tolerant [Stream] pipelines.
///
/// In contexts like handling delayed network requests or eager LLM initializations,
/// a stalled [Future] normally throws a [TimeoutException] which can crash unhandled
/// asynchronous boundaries. This extension isolates those exceptions, converting
/// time-bound operations into self-closing streams that integrate cleanly with
/// reactive UI layers or fallback stream generators.
extension OnFuture<T> on Future<T> {
  /// Transforms this [Future] into a single-element [Stream] that enforces a
  /// maximum execution duration, gracefully suppressing timeout failures.
  ///
  /// If the underlying future completes successfully within the specified [timeLimit],
  /// its materialized value is emitted, and the stream closes. However, if the
  /// operation exceeds [timeLimit], the internal [TimeoutException] is swallowed,
  /// the stream closes entirely empty (yielding no elements), and the optional
  /// [onTimeout] callback is synchronously invoked.
  ///
  /// Any non-timeout errors native to the future (e.g., `StateError` or network
  /// failures) are propagated downward into the returned stream as error events.
  ///
  /// ### Example
  /// ```dart
  /// // Gracefully handle long-polling network requests without try-catch blocks
  /// final modelsStream = fetchModelsFromServer()
  ///   .timeoutAsStream(
  ///     timeLimit: const Duration(seconds: 5),
  ///     onTimeout: () => print('Fetch took too long, falling back...'),
  ///   );
  ///
  /// await for (final models in modelsStream) {
  ///   // Will not execute if the fetch timed out
  ///   print('Loaded \${models.length} models');
  /// }
  /// ```
  Stream<T> timeoutAsStream({
    required Duration timeLimit,
    void Function()? onTimeout,
  }) async* {
    try {
      yield await timeout(timeLimit);
    } on TimeoutException {
      onTimeout?.call();
    }
  }
}
