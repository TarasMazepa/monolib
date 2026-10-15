/// Extension on a function that returns a [Future], providing utility methods.
extension OnFutureFunction<T> on Future<T> Function() {
  /// Invokes the function and retries it upon failure up to [times] times.
  ///
  /// This method repeatedly awaits the [Future] returned by this function. If it
  /// succeeds, the result is returned immediately. If it throws an exception,
  /// it will catch the exception and retry up to [times] total attempts.
  /// If all attempts fail, it will rethrow the very first exception encountered.
  ///
  /// By default, [times] is set to 3. If [times] is less than or equal to 0,
  /// it will not attempt to execute the function and will throw `null`.
  ///
  /// Example:
  /// ```dart
  /// Future<String> fetchData() async {
  ///   // Simulate a flaky network request
  ///   throw Exception('Network error');
  /// }
  ///
  /// // Retries `fetchData` up to 5 times before throwing the exception.
  /// await fetchData.asyncCallWithRetryOnFailure(times: 5);
  /// ```
  Future<T> asyncCallWithRetryOnFailure({int times = 3}) async {
    dynamic toRethrow;
    for (int i = 0; i < times && times > 0; i++) {
      try {
        return await this();
      } catch (e) {
        toRethrow ??= e;
      }
    }
    throw toRethrow;
  }
}

/// Invokes the given [call] function and retries it upon failure.
///
/// This is a convenience wrapper around [OnFutureFunction.asyncCallWithRetryOnFailure].
/// It repeatedly awaits the [Future] returned by [call]. If it succeeds, the
/// result is returned immediately. If it throws an exception, it retries up to
/// [times] total attempts (defaulting to 3). If all attempts fail, the first
/// exception caught is rethrown.
///
/// Example:
/// ```dart
/// Future<int> getNumber() async {
///   // Some flaky operation
///   return 42;
/// }
///
/// final result = await asyncRetryOnFailure(getNumber, times: 3);
/// ```
Future<T> asyncRetryOnFailure<T>(Future<T> Function() call, {int times = 3}) {
  return call.asyncCallWithRetryOnFailure(times: times);
}
