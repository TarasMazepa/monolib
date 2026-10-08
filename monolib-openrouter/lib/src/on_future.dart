import 'dart:async';

extension OnFuture<T> on Future<T> {
  /// Returns a stream that emits the value of this future, or closes without
  /// emitting and calls [onTimeout] when the future doesn't complete within
  /// [timeLimit].
  ///
  /// Errors of this future are emitted by the returned stream.
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
