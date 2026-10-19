part of 'exception_strategy.dart';

/// An [ExceptionStrategy] that immediately aborts dispatch upon encountering
/// the first synchronous exception.
///
/// Any exception thrown by a child sink propagates directly to the caller,
/// leaving subsequent sinks in the collection unprocessed. If all sinks must
/// be notified even when some fail, use [ExceptionStrategy.aggregate] instead.
///
/// Exposed via [ExceptionStrategy.failFast].
///
/// Example:
/// ```dart
/// final sink1 = StreamController<int>();
/// final sink2 = StreamController<int>()..close();
/// final sink3 = StreamController<int>();
///
/// final compositeSink = CompositeEventSink([sink1.sink, sink2.sink, sink3.sink]);
///
/// try {
///   compositeSink.add(42);
/// } catch (e) {
///   // sink1 receives 42, sink2 throws StateError, and sink3 is not reached.
/// }
/// ```
class _FailFastExceptionStrategy implements ExceptionStrategy {
  /// Creates a fail-fast exception strategy.
  const _FailFastExceptionStrategy();

  /// Invokes [action] on each sink in [sinks] sequentially without catching
  /// exceptions.
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
