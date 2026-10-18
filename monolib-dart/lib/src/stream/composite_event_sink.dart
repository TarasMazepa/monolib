import 'dart:async';

import 'package:monolib_dart/src/stream/composite_event_sink/exception_strategy.dart';

/// An [EventSink] that forwards all events to multiple child [EventSink]s.
///
/// [CompositeEventSink] distributes [add], [addError], and [close] calls across
/// a collection of downstream sinks. If a child sink throws a synchronous
/// exception during dispatch, handling is delegated to the configured
/// [ExceptionStrategy] (for example, failing immediately, ignoring errors, or
/// collecting multiple errors into a `CompositeSinkException`).
///
/// Example:
/// ```dart
/// final sink1 = StreamController<int>();
/// final sink2 = StreamController<int>();
/// final compositeSink = CompositeEventSink([sink1.sink, sink2.sink]);
///
/// compositeSink.add(42); // Forwards 42 to both sink1 and sink2.
/// compositeSink.close(); // Closes both sink1 and sink2.
/// ```
class CompositeEventSink<T> implements EventSink<T> {
  final List<EventSink<T>> _sinks;
  final bool _throwOnClosed;
  final ExceptionStrategy _exceptionStrategy;

  bool _closed = false;

  /// Creates a [CompositeEventSink] that forwards events to [sinks].
  ///
  /// The [throwOnClosed] parameter controls whether calling [add], [addError],
  /// or [close] after this sink has been closed throws a [StateError]
  /// (defaults to `false`, which silently ignores subsequent calls).
  ///
  /// The [exceptionStrategy] controls how synchronous exceptions thrown by
  /// child sinks are handled (defaults to [ExceptionStrategy.failFast]).
  CompositeEventSink(
    Iterable<EventSink<T>> sinks, {
    bool throwOnClosed = false,
    ExceptionStrategy exceptionStrategy = ExceptionStrategy.failFast,
  })  : _sinks = sinks.toList(),
        _throwOnClosed = throwOnClosed,
        _exceptionStrategy = exceptionStrategy;

  /// Forwards [data] to all child sinks.
  ///
  /// If this sink is already closed, throws a [StateError] when configured with
  /// `throwOnClosed: true`, or does nothing otherwise.
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

  /// Closes this composite sink and forwards [close] to all child sinks.
  ///
  /// Once closed, subsequent calls to [add], [addError], or [close] throw a
  /// [StateError] when configured with `throwOnClosed: true`, or are ignored
  /// otherwise.
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

  /// Forwards [error] and optional [stackTrace] to all child sinks.
  ///
  /// If this sink is already closed, throws a [StateError] when configured with
  /// `throwOnClosed: true`, or does nothing otherwise.
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
