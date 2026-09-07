import 'dart:async';

import 'aggregate_exception_strategy.dart';
import 'composite_sink_error.dart';
import 'fail_fast_exception_strategy.dart';
import 'swallow_exception_strategy.dart';

/// Strategy to handle exceptions thrown by downstream sinks in a [CompositeEventSink].
abstract class ExceptionStrategy {
  const ExceptionStrategy();

  /// Throws the first exception encountered immediately, halting the dispatch.
  static const ExceptionStrategy failFast = FailFastExceptionStrategy();

  /// Ignores any exceptions thrown by child sinks, continuing to the next sink.
  static const ExceptionStrategy swallow = SwallowExceptionStrategy();

  /// Collects all exceptions thrown by child sinks and throws a single [CompositeSinkError] at the end.
  static const ExceptionStrategy aggregate = AggregateExceptionStrategy();

  /// Dispatches the [action] to the [sinks].
  void dispatch<T>(
      Iterable<EventSink<T>> sinks, void Function(EventSink<T> sink) action);
}
