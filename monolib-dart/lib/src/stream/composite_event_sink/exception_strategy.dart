import 'dart:async';

import 'package:monolib_dart/src/stream/composite_event_sink/composite_sink_exception.dart';

part 'aggregate_exception_strategy.dart';
part 'fail_fast_exception_strategy.dart';
part 'swallow_exception_strategy.dart';

/// Strategy to handle exceptions thrown by downstream sinks in a [CompositeEventSink].
abstract class ExceptionStrategy {
  const ExceptionStrategy();

  /// Throws the first exception encountered immediately, halting the dispatch.
  static const ExceptionStrategy failFast = _FailFastExceptionStrategy();

  /// Ignores any exceptions thrown by child sinks, continuing to the next sink.
  static const ExceptionStrategy swallow = _SwallowExceptionStrategy();

  /// Collects all exceptions thrown by child sinks and throws a single [CompositeSinkException] at the end, or the original exception if only one was thrown.
  static const ExceptionStrategy aggregate = _AggregateExceptionStrategy();

  /// Dispatches the [action] to the [sinks].
  void dispatch<T>(
      Iterable<EventSink<T>> sinks, void Function(EventSink<T> sink) action);
}
