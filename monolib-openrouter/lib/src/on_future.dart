import 'dart:async';

/// Extension on [Future] that converts time-bounded futures into streams that
/// close gracefully on timeout.
extension OnFuture<T> on Future<T> {
  /// Converts this [Future] into a single-element [Stream] that closes without
  /// emitting an error if [timeLimit] expires.
  ///
  /// If the future completes within [timeLimit], its value is emitted and the
  /// stream closes. If [timeLimit] is exceeded, the [TimeoutException] is
  /// caught, the optional [onTimeout] callback is invoked, and the stream
  /// closes empty.
  ///
  /// Non-timeout errors (such as [StateError] or network failures) are
  /// forwarded to the returned stream as error events.
  ///
  /// Example:
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
  ///   print('Loaded ${models.length} models');
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
