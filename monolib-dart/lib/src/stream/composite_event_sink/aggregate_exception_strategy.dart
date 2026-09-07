part of 'exception_strategy.dart';

/// Strategy that collects all exceptions thrown by child sinks and throws a single [CompositeSinkException] at the end, or the original exception if only one was thrown.
class _AggregateExceptionStrategy implements ExceptionStrategy {
  const _AggregateExceptionStrategy();

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

    switch (errors) {
      case [final error]:
        throw error;
      case [_, ...]:
        throw CompositeSinkException(errors);
    }
  }
}
