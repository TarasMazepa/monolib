import 'dart:async';

import 'package:monolib_dart/src/stream/composite_event_sink/composite_sink_exception.dart';

part 'aggregate_exception_strategy.dart';
part 'fail_fast_exception_strategy.dart';
part 'swallow_exception_strategy.dart';

/// A strategy for handling synchronous exceptions thrown while dispatching an
/// operation across multiple [EventSink]s.
///
/// When an event is forwarded to multiple sinks (such as in a
/// `CompositeEventSink`), individual sinks may throw synchronous exceptions
/// (for example, if a sink is already closed). Implementations of
/// [ExceptionStrategy] determine whether dispatch halts on the first error
/// ([failFast]), ignores errors ([swallow]), or collects errors after
/// notifying all sinks ([aggregate]).
///
/// Custom strategies can be created by implementing [ExceptionStrategy].
///
/// Example:
/// ```dart
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
  /// Creates an [ExceptionStrategy].
  const ExceptionStrategy();

  /// A strategy that immediately rethrows the first encountered exception,
  /// halting dispatch to any remaining sinks.
  static const ExceptionStrategy failFast = _FailFastExceptionStrategy();

  /// A strategy that catches and ignores any synchronous exceptions thrown by
  /// individual target sinks.
  static const ExceptionStrategy swallow = _SwallowExceptionStrategy();

  /// A strategy that collects exceptions thrown by target sinks so that
  /// dispatch completes for all sinks before reporting failures.
  ///
  /// If multiple sinks fail, throws a [CompositeSinkException] containing all
  /// caught errors. If only one sink fails, rethrows the original exception
  /// directly.
  static const ExceptionStrategy aggregate = _AggregateExceptionStrategy();

  /// Executes [action] on each sink in [sinks] using this strategy's
  /// error-handling behavior.
  void dispatch<T>(
    Iterable<EventSink<T>> sinks,
    void Function(EventSink<T> sink) action,
  );
}
