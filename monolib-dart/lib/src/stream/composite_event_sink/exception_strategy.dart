import 'dart:async';

import 'package:monolib_dart/src/stream/composite_event_sink/composite_sink_exception.dart';

part 'aggregate_exception_strategy.dart';
part 'fail_fast_exception_strategy.dart';
part 'swallow_exception_strategy.dart';

/// Defines the architectural strategy for handling synchronous exceptions that occur
/// during event broadcasting in a [CompositeEventSink].
///
/// When a single event is dispatched to multiple child sinks, one or more of
/// those sinks might throw an exception (e.g., if a downstream [EventSink] is
/// already closed, or if custom formatting logic fails). This abstract class
/// dictates how those exceptions are surfaced to the caller.
///
/// Implementations of this strategy determine whether the broadcast stops
/// immediately, ignores errors silently, or accumulates them for a comprehensive
/// report. This ensures that callers of [CompositeEventSink] can cleanly separate
/// their data dispatching logic from their error recovery requirements.
///
/// Example usage:
/// ```dart
/// // Create a composite sink that forwards to a local database and a remote server.
/// // We use the [aggregate] strategy so that a failure in one destination
/// // does not prevent the other from receiving the data, but we can still
/// // detect and handle both failures afterward.
/// final compositeSink = CompositeEventSink(
///   [localDbSink, remoteApiSink],
///   exceptionStrategy: ExceptionStrategy.aggregate,
/// );
///
/// try {
///   compositeSink.add(myData);
/// } on CompositeSinkException catch (e) {
///   print('Some destinations failed: ${e.errors}');
/// }
/// ```
abstract class ExceptionStrategy {
  /// Base const constructor for subclasses to implement custom error-handling
  /// strategies without introducing state overhead.
  const ExceptionStrategy();

  /// A strategy that immediately throws the first encountered exception,
  /// halting dispatch to any remaining sinks.
  ///
  /// This is the default strict behavior. Use this when partial data delivery
  /// is unacceptable and you must immediately abort the operation if any single
  /// child sink fails.
  static const ExceptionStrategy failFast = _FailFastExceptionStrategy();

  /// A fault-tolerant strategy that intentionally catches and ignores any
  /// synchronous exceptions thrown by individual target sinks.
  ///
  /// This is suitable for non-critical pipelines (like logging or telemetry)
  /// where the primary data flow must never be interrupted by a failing destination.
  static const ExceptionStrategy swallow = _SwallowExceptionStrategy();

  /// A strategy that collects all exceptions thrown by child sinks during a
  /// dispatch pass, allowing iteration to complete for all destinations.
  ///
  /// If multiple sinks fail, it wraps all encountered errors into a single
  /// [CompositeSinkException] and throws it after the loop finishes.
  /// If only one child sink fails, it unwraps and throws the original exception
  /// instead, keeping single-failure stack traces clean.
  static const ExceptionStrategy aggregate = _AggregateExceptionStrategy();

  /// Executes the provided [action] across the given collection of [sinks],
  /// applying this specific error-handling behavior.
  ///
  /// The [action] is typically a closure that invokes [EventSink.add],
  /// [EventSink.addError], or [EventSink.close] on the individual child [sink].
  /// Depending on the concrete implementation, exceptions thrown by [action]
  /// might be thrown immediately, caught and stored, or silently discarded.
  void dispatch<T>(
    Iterable<EventSink<T>> sinks,
    void Function(EventSink<T> sink) action,
  );
}
