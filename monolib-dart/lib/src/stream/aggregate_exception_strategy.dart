import 'dart:async';

import 'composite_sink_error.dart';
import 'exception_strategy.dart';

/// Strategy that collects all exceptions thrown by child sinks and throws a single [CompositeSinkError] at the end.
class AggregateExceptionStrategy implements ExceptionStrategy {
  const AggregateExceptionStrategy();

  @override
  void dispatch<T>(
      Iterable<EventSink<T>> sinks, void Function(EventSink<T> sink) action) {
    final List<Object> errors = [];
    for (final sink in sinks) {
      try {
        action(sink);
      } catch (e) {
        errors.add(e);
      }
    }

    if (errors.isNotEmpty) {
      throw CompositeSinkError(errors);
    }
  }
}
