import 'dart:async';

import 'package:monolib_dart/src/stream/composite_event_sink/exception_strategy.dart';

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

  @override
  void add(T data) {
    if (_closed) {
      if (_throwOnClosed) {
        throw StateError('Cannot perform operation after closing');
      }
      return;
    }
    _exceptionStrategy.dispatch(_sinks, (sink) => sink.add(data));
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
    _exceptionStrategy.dispatch(_sinks, (sink) => sink.close());
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    if (_closed) {
      if (_throwOnClosed) {
        throw StateError('Cannot perform operation after closing');
      }
      return;
    }
    _exceptionStrategy.dispatch(
      _sinks,
      (sink) => sink.addError(error, stackTrace),
    );
  }
}
