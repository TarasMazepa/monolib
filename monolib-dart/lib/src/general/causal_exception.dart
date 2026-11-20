/// An [Exception] that carries a [message], optional [cause],
/// [causeStackTrace], and [suppressed] errors.
///
/// Useful when wrapping a caught error with additional context while preserving
/// the original [cause], its [causeStackTrace], and any secondary failures
/// (such as errors thrown during cleanup or fallback steps) in [suppressed].
///
/// Example:
/// ```dart
/// try {
///   throw StateError('Connection lost');
/// } catch (error, stackTrace) {
///   CausalException.throwNew(
///     'Failed to save record',
///     cause: error,
///     causeStackTrace: stackTrace,
///   );
/// }
/// ```
class CausalException implements Exception {
  /// Human-readable description of what failed.
  final String message;

  /// The underlying error that triggered this exception, if any.
  final Object? cause;

  /// Stack trace associated with [cause], if captured.
  final StackTrace? causeStackTrace;

  /// Secondary errors (for example, failures during cleanup or retries).
  final List<Object> suppressed;

  /// Creates a [CausalException] with a required [message] and optional
  /// [cause], [causeStackTrace], and [suppressed] errors.
  const CausalException(
    this.message, {
    this.cause,
    this.causeStackTrace,
    this.suppressed = const [],
  });

  /// Creates a [CausalException] and immediately throws it.
  static Never throwNew(
    String message, {
    Object? cause,
    StackTrace? causeStackTrace,
    List<Object> suppressed = const [],
  }) =>
      throw CausalException(
        message,
        cause: cause,
        causeStackTrace: causeStackTrace,
        suppressed: suppressed,
      );

  @override
  String toString() {
    final buffer = StringBuffer('CausalException: $message');
    if (cause != null) buffer.write(' (caused by: $cause)');
    if (suppressed.isNotEmpty) {
      buffer.write(' [${suppressed.length} suppressed]');
    }
    return buffer.toString();
  }
}
