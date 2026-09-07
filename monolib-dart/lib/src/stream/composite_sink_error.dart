/// An error thrown when [ExceptionStrategy.aggregate] is used and child sinks throw exceptions.
class CompositeSinkError implements Exception {
  /// The list of exceptions collected from child sinks.
  final List<Object> errors;

  /// Creates a new composite sink error with the provided [errors].
  CompositeSinkError(this.errors);

  @override
  String toString() =>
      'CompositeSinkError: ${errors.length} error(s) occurred.';
}
