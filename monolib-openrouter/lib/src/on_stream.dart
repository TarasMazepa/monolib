import 'dart:async';

/// Extension on [Stream] that provides graceful timeout termination without
/// emitting a [TimeoutException].
extension OnStream<T> on Stream<T> {
  /// Returns a [Stream] that closes instead of emitting a [TimeoutException]
  /// when no events arrive within [timeLimit].
  ///
  /// Useful for high-latency or chunked LLM response streams where a stalled
  /// connection should conclude the stream cleanly rather than propagating an
  /// unhandled timeout error.
  ///
  /// The [timeLimit] parameter specifies the maximum duration allowed between
  /// consecutive events before the stream closes. The optional [onTimeout]
  /// callback is invoked synchronously just before the underlying [EventSink]
  /// is closed.
  ///
  /// Example:
  /// ```dart
  /// final safeStream = rawOpenRouterStream.timeoutAndClose(
  ///   timeLimit: const Duration(seconds: 15),
  ///   onTimeout: () => print('LLM stream stalled, closing gracefully.'),
  /// );
  ///
  /// await for (final chunk in safeStream) {
  ///   // Process chunks normally; if 15 seconds elapse without a chunk,
  ///   // the loop simply exits instead of throwing.
  /// }
  /// ```
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
