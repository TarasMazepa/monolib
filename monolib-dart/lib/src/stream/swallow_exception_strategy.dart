import 'dart:async';

import 'exception_strategy.dart';

/// Strategy that ignores any exceptions thrown by child sinks, continuing to the next sink.
class SwallowExceptionStrategy implements ExceptionStrategy {
  const SwallowExceptionStrategy();

  @override
  void dispatch<T>(
      Iterable<EventSink<T>> sinks, void Function(EventSink<T> sink) action) {
    for (final sink in sinks) {
      try {
        action(sink);
      } catch (_) {
        // Swallow exception
      }
    }
  }
}
