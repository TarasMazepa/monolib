import 'dart:async';

/// Strategy to handle exceptions thrown by downstream sinks in a [CompositeEventSink].
enum ExceptionStrategy {
  /// Throws the first exception encountered immediately, halting the dispatch.
  failFast,

  /// Ignores any exceptions thrown by child sinks, continuing to the next sink.
  swallow,

  /// Collects all exceptions thrown by child sinks and throws a single [CompositeSinkError] at the end.
  aggregate,
}

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

/// A composite event sink that forwards events to multiple target sinks.
///
/// This class is useful when you have a single source of events but need to
/// broadcast those events to multiple destinations (sinks). It implements
/// [EventSink] and distributes [add], [addError], and [close] calls to all
/// provided child sinks.
class CompositeEventSink<T> implements EventSink<T> {
  final List<EventSink<T>> _sinks;
  final bool _throwOnClosed;
  final ExceptionStrategy _exceptionStrategy;

  bool _closed = false;

  /// Creates a new composite event sink that forwards events to the provided [sinks].
  ///
  /// The [throwOnClosed] parameter controls whether operations throw a [StateError]
  /// after [close] has been called (defaults to `false` for silent ignore).
  ///
  /// The [exceptionStrategy] controls how exceptions thrown by child sinks are handled
  /// (defaults to [ExceptionStrategy.failFast]).
  CompositeEventSink(
    Iterable<EventSink<T>> sinks, {
    bool throwOnClosed = false,
    ExceptionStrategy exceptionStrategy = ExceptionStrategy.failFast,
  })  : _sinks = sinks.toList(),
        _throwOnClosed = throwOnClosed,
        _exceptionStrategy = exceptionStrategy;

  void _dispatch(void Function(EventSink<T> sink) action) {
    final errors = <Object>[];
    for (final sink in _sinks) {
      switch (_exceptionStrategy) {
        case ExceptionStrategy.failFast:
          action(sink);
          break;
        case ExceptionStrategy.swallow:
          try {
            action(sink);
          } catch (_) {
            // Swallow exception
          }
          break;
        case ExceptionStrategy.aggregate:
          try {
            action(sink);
          } catch (e) {
            errors.add(e);
          }
          break;
      }
    }

    if (_exceptionStrategy == ExceptionStrategy.aggregate &&
        errors.isNotEmpty) {
      throw CompositeSinkError(errors);
    }
  }

  @override
  void add(T data) {
    if (_closed) {
      if (_throwOnClosed) {
        throw StateError('Cannot perform operation after closing');
      }
      return;
    }
    _dispatch((sink) => sink.add(data));
  }

  @override
  void close() {
    if (_closed) {
      if (_throwOnClosed) {
        throw StateError('Cannot perform operation after closing');
      }
      return;
    }
    _closed = true;
    _dispatch((sink) => sink.close());
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    if (_closed) {
      if (_throwOnClosed) {
        throw StateError('Cannot perform operation after closing');
      }
      return;
    }
    _dispatch((sink) => sink.addError(error, stackTrace));
  }
}
