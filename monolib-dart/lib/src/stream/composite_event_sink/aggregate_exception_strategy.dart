part of 'exception_strategy.dart';

/// A fault-tolerant [ExceptionStrategy] that defers synchronous exception propagation
/// to ensure a broadcasting operation completes entirely before reporting failures.
///
/// In multiplexing stream architectures like [CompositeEventSink], a single event or lifecycle
/// signal (e.g., [EventSink.add] or [EventSink.close]) must be reliably fanned out to multiple
/// downstream sinks. If an eager strategy (like [ExceptionStrategy.failFast]) is used, an exception
/// in one child sink abruptly halts the iteration, leaving subsequent sinks unnotified and creating
/// unpredictable partial-state architectures.
///
/// `_AggregateExceptionStrategy` solves this by wrapping each sink's dispatch invocation in an
/// individual `try/catch` block. It silently accumulates any thrown exceptions while forcing the
/// loop to continue. Once all sinks have been processed, it evaluates the caught errors:
/// * If no errors occurred, it returns normally.
/// * If exactly **one** error occurred, it transparently unwraps and rethrows that original error,
///   preventing unnecessary exception-wrapping overhead.
/// * If **multiple** errors occurred, it packages them into a single [CompositeSinkException],
///   allowing the caller to inspect the full breadth of the failure.
///
/// This strategy is typically accessed via the [ExceptionStrategy.aggregate] constant and
/// injected into a [CompositeEventSink] constructor.
///
/// ### Example
/// ```dart
/// final sinkA = StreamController<int>()..close(); // Closed early, throws StateError on add
/// final sinkB = StreamController<int>();          // Will succeed
/// final sinkC = StreamController<int>()..close(); // Closed early, throws StateError on add
///
/// final composite = CompositeEventSink(
///   [sinkA.sink, sinkB.sink, sinkC.sink],
///   exceptionStrategy: ExceptionStrategy.aggregate,
/// );
///
/// try {
///   // The loop will not crash on sinkA.
///   // sinkB will successfully receive 42.
///   // sinkC will throw, and its error will also be caught.
///   composite.add(42);
/// } on CompositeSinkException catch (e) {
///   print('Errors caught: ${e.errors.length}'); // Prints 2
/// }
/// ```
class _AggregateExceptionStrategy implements ExceptionStrategy {
  /// Instantiates the deferred execution exception strategy.
  ///
  /// This constructor is typically only invoked once internally to define the
  /// singleton [ExceptionStrategy.aggregate] constant.
  const _AggregateExceptionStrategy();

  /// Dispatches the given [action] across all provided [sinks], accumulating any
  /// synchronous exceptions thrown along the way.
  ///
  /// This method iterates sequentially over the `Iterable` of [sinks]. For each [sink],
  /// it invokes [action]. If [action] throws, the exception is caught and appended to
  /// an internal list, and iteration continues to the next sink.
  ///
  /// After iteration completes, it analyzes the list of caught errors:
  /// - 0 errors: Returns silently.
  /// - 1 error: Throws the original exception directly.
  /// - 2+ errors: Throws a [CompositeSinkException] containing all accumulated errors.
  @override
  void dispatch<T>(
    Iterable<EventSink<T>> sinks,
    void Function(EventSink<T> sink) action,
  ) {
    final List<Object> errors = [];
    for (final sink in sinks) {
      try {
        action(sink);
      } catch (e) {
        errors.add(e);
      }
    }

    switch (errors) {
      case [final error]:
        throw error;
      case [_, ...]:
        throw CompositeSinkException(errors);
    }
  }
}
