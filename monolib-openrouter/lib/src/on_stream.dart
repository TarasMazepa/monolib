import 'dart:async';

/// Provides fault-tolerant utilities for asynchronous event pipelines by extending the native capabilities of [Stream].
///
/// This extension bridges standard streams into robust data flows by offering
/// mechanisms to safely suppress fatal asynchronous exceptions—such as replacing
/// unhandled [TimeoutException]s with graceful stream termination. It is
/// particularly critical when processing high-latency network responses (e.g.,
/// chunked LLM API streams from OpenRouter) where a slow response should gracefully
/// conclude the stream rather than crashing the reactive pipeline.
extension OnStream<T> on Stream<T> {
  /// Returns a [Stream] that safely closes itself instead of emitting a
  /// [TimeoutException] when no events are received within the specified [timeLimit].
  ///
  /// Architecturally, [timeoutAndClose] prevents unhandled timeout exceptions from
  /// propagating into reactive pipelines (like UI builders or long-running stream
  /// processors). By converting a time-bound operation into a self-closing stream,
  /// consumers (like `StreamBuilder`s) can naturally reach a 'done' state when a
  /// network request stalls or an LLM generation abruptly stops.
  ///
  /// The [timeLimit] parameter defines the maximum allowed duration between
  /// consecutive events before the stream forces termination.
  ///
  /// The optional [onTimeout] callback is invoked synchronously right before the
  /// underlying `EventSink` is closed. This provides a hook to update external
  /// state, log the timeout, or trigger cleanup logic without manually intercepting
  /// stream lifecycle events.
  ///
  /// Example usage for an LLM response stream:
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
