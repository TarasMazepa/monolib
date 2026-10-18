import 'package:monolib_dart/src/stream/composite_event_sink/exception_strategy.dart';

/// An exception that aggregates multiple errors thrown while dispatching an
/// event across multiple sinks.
///
/// Thrown by [ExceptionStrategy.aggregate] (for example, in a
/// `CompositeEventSink`) when two or more child sinks throw synchronous
/// exceptions during the same dispatch pass. If only a single sink fails,
/// [ExceptionStrategy.aggregate] rethrows that original exception directly.
///
/// Example:
/// ```dart
/// final sink1 = StreamController<int>()..close();
/// final sink2 = StreamController<int>();
/// final sink3 = StreamController<int>()..close();
///
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
  /// The exceptions caught from failing child sinks during dispatch.
  ///
  /// Contains at least two elements when thrown by
  /// [ExceptionStrategy.aggregate].
  final List<Object> errors;

  /// Creates a [CompositeSinkException] wrapping the collected [errors].
  CompositeSinkException(this.errors);

  @override
  String toString() =>
      'CompositeSinkException: ${errors.length} error(s) occurred.';
}
