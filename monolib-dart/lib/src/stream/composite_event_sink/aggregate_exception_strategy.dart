part of 'exception_strategy.dart';

/// An [ExceptionStrategy] that dispatches to every sink before reporting any
/// synchronous exceptions.
///
/// Each sink's dispatch invocation is wrapped in a `try`/`catch` block so that
/// an error in one sink does not prevent remaining sinks in a
/// `CompositeEventSink` from receiving the event. After all sinks have been
/// processed:
/// - If no errors occurred, [dispatch] returns normally.
/// - If a single error occurred, that original error is rethrown directly.
/// - If multiple errors occurred, they are thrown together in a
///   [CompositeSinkException].
///
/// Exposed via [ExceptionStrategy.aggregate].
///
/// Example:
/// ```dart
/// final sinkA = StreamController<int>()..close();
/// final sinkB = StreamController<int>();
/// final sinkC = StreamController<int>()..close();
///
/// final composite = CompositeEventSink(
///   [sinkA.sink, sinkB.sink, sinkC.sink],
///   exceptionStrategy: ExceptionStrategy.aggregate,
/// );
///
/// try {
///   composite.add(42);
/// } on CompositeSinkException catch (e) {
///   print('Errors caught: ${e.errors.length}'); // Prints 2
/// }
/// ```
class _AggregateExceptionStrategy implements ExceptionStrategy {
  /// Creates an aggregating exception strategy.
  const _AggregateExceptionStrategy();

  /// Invokes [action] on each sink in [sinks], collecting any synchronous
  /// exceptions thrown during iteration.
  ///
  /// Rethrows the single error if only one sink failed, or throws a
  /// [CompositeSinkException] if two or more sinks failed.
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
