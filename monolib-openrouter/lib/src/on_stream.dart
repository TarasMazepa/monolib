import 'dart:async';

extension OnStream<T> on Stream<T> {
  /// Returns a stream that closes and calls [onTimeout] when this stream
  /// doesn't emit an event within [timeLimit] of the previous one, instead of
  /// emitting a [TimeoutException].
  Stream<T> timeoutAndClose({
    required Duration timeLimit,
    void Function()? onTimeout,
  }) =>
      timeout(
        timeLimit,
        onTimeout: (sink) {
          onTimeout?.call();
          sink.close();
        },
      );
}
