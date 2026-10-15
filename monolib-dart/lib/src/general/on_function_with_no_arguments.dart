/// Extension methods for zero-argument functions returning [T].
extension OnFunctionWithNoArguments<T> on T Function() {
  /// Calls the function and retries it up to [times] times if it throws an exception.
  ///
  /// If the function fails [times] times consecutively, the first exception
  /// caught will be rethrown. If [times] is less than or equal to 0, it throws an
  /// [ArgumentError].
  ///
  /// Example:
  /// ```dart
  /// int unstableCall() { ... }
  /// int result = unstableCall.callWithRetryOnFailure(times: 3);
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

/// A helper function that executes [call] with retry logic.
///
/// This behaves identically to [OnFunctionWithNoArguments.callWithRetryOnFailure].
/// It attempts to execute [call] up to [times] times if it throws an exception.
///
/// Example:
/// ```dart
/// int unstableCall() { ... }
/// int result = retryOnFailure(unstableCall, times: 3);
/// ```
T retryOnFailure<T>(T Function() call, {int times = 3}) {
  return call.callWithRetryOnFailure(times: times);
}
