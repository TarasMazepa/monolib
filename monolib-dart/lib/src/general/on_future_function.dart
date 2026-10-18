/// Extension on zero-argument functions returning a [Future] of [T] that
/// provides retry logic.
extension OnFutureFunction<T> on Future<T> Function() {
  /// Invokes this function and retries up to [times] total attempts if the
  /// returned [Future] throws.
  ///
  /// Returns the result immediately on success. If all [times] attempts throw,
  /// rethrows the first caught exception.
  ///
  /// Throws an [ArgumentError] if [times] is less than or equal to `0`.
  ///
  /// Example:
  /// ```dart
  /// Future<int> unstableCall() async => 42;
  /// final result = await unstableCall.asyncCallWithRetryOnFailure(times: 3);
  /// ```
  Future<T> asyncCallWithRetryOnFailure({int times = 3}) async {
    if (times <= 0) {
      throw ArgumentError.value(times, 'times', 'must be greater than 0');
    }
    dynamic toRethrow;
    for (int i = 0; i < times; i++) {
      try {
        return await this();
      } catch (e) {
        toRethrow ??= e;
      }
    }
    throw toRethrow;
  }
}

/// Invokes [call] and retries up to [times] total attempts if the returned
/// [Future] throws.
///
/// Convenience wrapper around [OnFutureFunction.asyncCallWithRetryOnFailure].
///
/// Throws an [ArgumentError] if [times] is less than or equal to `0`.
///
/// Example:
/// ```dart
/// Future<int> unstableCall() async => 42;
/// final result = await asyncRetryOnFailure(unstableCall, times: 3);
/// ```
Future<T> asyncRetryOnFailure<T>(Future<T> Function() call, {int times = 3}) {
  return call.asyncCallWithRetryOnFailure(times: times);
}
