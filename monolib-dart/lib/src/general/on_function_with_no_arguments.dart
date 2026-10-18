/// Extension on zero-argument functions returning [T] that provides retry
/// logic.
extension OnFunctionWithNoArguments<T> on T Function() {
  /// Invokes this function and retries up to [times] total attempts if it
  /// throws.
  ///
  /// Returns the result immediately on success. If all [times] attempts throw,
  /// rethrows the first caught exception.
  ///
  /// Throws an [ArgumentError] if [times] is less than or equal to `0`.
  ///
  /// Example:
  /// ```dart
  /// int unstableCall() => 42;
  /// final result = unstableCall.callWithRetryOnFailure(times: 3);
  /// ```
  T callWithRetryOnFailure({int times = 3}) {
    if (times <= 0) {
      throw ArgumentError.value(times, 'times', 'must be greater than 0');
    }
    dynamic toRethrow;
    for (int i = 0; i < times; i++) {
      try {
        return this();
      } catch (e) {
        toRethrow ??= e;
      }
    }
    throw toRethrow;
  }
}

/// Invokes [call] and retries up to [times] total attempts if it throws.
///
/// Convenience wrapper around
/// [OnFunctionWithNoArguments.callWithRetryOnFailure].
///
/// Throws an [ArgumentError] if [times] is less than or equal to `0`.
///
/// Example:
/// ```dart
/// int unstableCall() => 42;
/// final result = retryOnFailure(unstableCall, times: 3);
/// ```
T retryOnFailure<T>(T Function() call, {int times = 3}) {
  return call.callWithRetryOnFailure(times: times);
}
