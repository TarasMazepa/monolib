import 'dart:async';

import 'exception_strategy.dart';

/// Strategy that throws the first exception encountered immediately, halting the dispatch.
class FailFastExceptionStrategy implements ExceptionStrategy {
  const FailFastExceptionStrategy();

  @override
  void dispatch<T>(
      Iterable<EventSink<T>> sinks, void Function(EventSink<T> sink) action) {
    for (final sink in sinks) {
      action(sink);
    }
  }
}
