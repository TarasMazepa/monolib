part of 'exception_strategy.dart';

/// An [ExceptionStrategy] that catches and ignores synchronous exceptions
/// thrown by target sinks.
///
/// When an exception is thrown by a sink during [dispatch], it is discarded
/// so that remaining sinks in a `CompositeEventSink` continue to receive the
/// event.
///
/// Exposed via [ExceptionStrategy.swallow].
///
/// Example:
/// ```dart
/// final compositeSink = CompositeEventSink(
///   [localLoggerSink, remoteAnalyticsSink],
///   exceptionStrategy: ExceptionStrategy.swallow,
/// );
/// ```
class _SwallowExceptionStrategy implements ExceptionStrategy {
  /// Creates an exception-swallowing strategy.
  const _SwallowExceptionStrategy();

  /// Invokes [action] on each sink in [sinks], catching and ignoring any
  /// synchronous exceptions.
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
