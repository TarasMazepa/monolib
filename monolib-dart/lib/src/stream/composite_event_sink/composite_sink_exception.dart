import 'package:monolib_dart/src/stream/composite_event_sink/exception_strategy.dart';

/// An exception that aggregates multiple errors encountered during a broadcast dispatch operation.
///
/// In stream processing architectures where a single event is forwarded to multiple
/// downstream sinks (like `CompositeEventSink`), one or more of these child sinks may
/// throw synchronous exceptions during the dispatch. Instead of halting immediately and leaving
/// some sinks unnotified, an aggregating strategy continues to notify all remaining sinks,
/// collects any exceptions that occur, and ultimately throws a [CompositeSinkException]
/// to report all failures at once.
///
/// This exception is specifically emitted by [ExceptionStrategy.aggregate] when two or
/// more child sinks fail. (If only a single sink fails, [ExceptionStrategy.aggregate]
/// unwraps and throws that original exception directly).
///
/// ### Example
/// ```dart
/// final compositeSink = CompositeEventSink<int>(
///   [sink1.sink, sink2.sink, sink3.sink],
///   exceptionStrategy: ExceptionStrategy.aggregate,
/// );
///
/// try {
///   compositeSink.add(42);
/// } on CompositeSinkException catch (e) {
///   print('Failed to notify all sinks. Errors: ${e.errors}');
/// }
/// ```
class CompositeSinkException implements Exception {
  /// The collection of underlying exceptions caught from the failing child sinks.
  ///
  /// This list is guaranteed to contain at least two elements, as single-error
  /// scenarios bypass [CompositeSinkException] and throw the underlying error directly.
  final List<Object> errors;

  /// Constructs an aggregate exception encompassing multiple collected [errors].
  ///
  /// The [errors] list should contain all exceptions caught sequentially during
  /// the dispatch loop.
  CompositeSinkException(this.errors);

  @override
  String toString() =>
      'CompositeSinkException: ${errors.length} error(s) occurred.';
}
