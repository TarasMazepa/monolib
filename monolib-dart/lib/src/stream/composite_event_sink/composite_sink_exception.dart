import 'package:monolib_dart/src/stream/composite_event_sink/exception_strategy.dart';

/// An exception thrown when [ExceptionStrategy.aggregate] is used and child sinks throw exceptions.
class CompositeSinkException implements Exception {
  /// The list of exceptions collected from child sinks.
  final List<Object> errors;

  /// Creates a new composite sink exception with the provided [errors].
  CompositeSinkException(this.errors);

  @override
  String toString() =>
      'CompositeSinkException: ${errors.length} error(s) occurred.';
}
