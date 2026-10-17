part of 'exception_strategy.dart';

/// A strict execution strategy for [CompositeEventSink] that immediately aborts
/// broadcasting upon encountering the first synchronous exception.
///
/// Architecturally, `_FailFastExceptionStrategy` is the default policy exposed via
/// [ExceptionStrategy.failFast]. It provides the standard Dart execution behavior:
/// an unhandled exception thrown by an individual child sink (e.g., a `StateError`
/// from adding to a closed [StreamController]) will propagate directly up the
/// call stack to the caller of [CompositeEventSink.add] or [CompositeEventSink.close].
///
/// **Warning:** Because it halts execution mid-iteration, using this strategy can
/// lead to partial-state architectural bugs where some sinks receive an event but
/// subsequent sinks in the collection do not. If atomic broadcasting or guaranteed
/// dispatch to all sinks is required, use [ExceptionStrategy.aggregate] instead.
///
/// Example usage (implicit default behavior):
/// ```dart
/// final sink1 = StreamController<int>();
/// final sink2 = StreamController<int>()..close(); // Closed early
/// final sink3 = StreamController<int>();
///
/// // Defaults to ExceptionStrategy.failFast internally.
/// final compositeSink = CompositeEventSink([sink1.sink, sink2.sink, sink3.sink]);
///
/// try {
///   compositeSink.add(42);
/// } catch (e) {
///   // sink1 successfully receives 42.
///   // sink2 throws StateError.
///   // The loop aborts; sink3 never receives 42.
/// }
/// ```
class _FailFastExceptionStrategy implements ExceptionStrategy {
  /// Instantiates a stateless strategy that halts iteration on the first exception.
  const _FailFastExceptionStrategy();

  /// Iterates through [sinks] sequentially, applying [action] to each.
  ///
  /// Any exception thrown during the execution of [action] on a particular sink
  /// will immediately bubble up, abruptly terminating the `for` loop and
  /// leaving the remaining sinks unprocessed.
  @override
  void dispatch<T>(
    Iterable<EventSink<T>> sinks,
    void Function(EventSink<T> sink) action,
  ) {
    for (final sink in sinks) {
      action(sink);
    }
  }
}
