part of 'exception_strategy.dart';

/// A fault-tolerant [ExceptionStrategy] that intentionally catches and ignores
/// any synchronous exceptions thrown by individual target sinks.
///
/// Within a [CompositeEventSink] architecture, this strategy is designed for
/// non-critical or "best-effort" broadcast pipelines—such as telemetry, logging,
/// or analytics systems—where the failure of a single destination should never
/// disrupt or crash the overall data flow.
///
/// When an exception is thrown by a specific [EventSink] during [dispatch],
/// it is immediately swallowed, allowing the iteration to proceed uninterrupted
/// to the remaining downstream sinks.
///
/// **Warning:** This will silently drop errors, making debugging difficult.
/// It should not be used in critical data paths where consistency is required.
///
/// Example usage:
/// ```dart
/// // Create a composite sink that won't fail if the remote analytics sink throws.
/// final compositeSink = CompositeEventSink(
///   [localLoggerSink, remoteAnalyticsSink],
///   exceptionStrategy: ExceptionStrategy.swallow,
/// );
/// ```
class _SwallowExceptionStrategy implements ExceptionStrategy {
  /// Constructs a silent exception-swallowing strategy.
  const _SwallowExceptionStrategy();

  /// Iterates through all provided [sinks], executing the given [action] on each.
  ///
  /// If the [action] throws a synchronous exception for a particular sink,
  /// the exception is caught and discarded, and the loop proceeds to the next sink.
  @override
  void dispatch<T>(
    Iterable<EventSink<T>> sinks,
    void Function(EventSink<T> sink) action,
  ) {
    for (final sink in sinks) {
      try {
        action(sink);
      } catch (_) {
        // Swallow exception
      }
    }
  }
}
