import 'dart:async';

import 'package:monolib_dart/src/stream/composite_event_sink/exception_strategy.dart';

/// A multiplexing [EventSink] that structurally bridges a single event source to
/// an arbitrary collection of downstream listeners or execution pipelines.
///
/// Within reactive architectures, it frequently becomes necessary to fork an event stream
/// dynamically (e.g., dispatching a telemetry event to both a local logger and a remote API).
/// Instead of manually wiring independent stream subscriptions or repeating `try-catch`
/// blocks across scattered callbacks, this class unifies the fan-out behavior into a
/// single sink interface.
///
/// It distributes [add], [addError], and [close] signals to all registered child sinks.
/// Crucially, it isolates the failure domain of independent sinks: if one destination throws
/// a synchronous error during dispatch (such as writing to a closed socket),
/// [CompositeEventSink] delegates to its injected [ExceptionStrategy]. This allows
/// developers to determine whether failures should fail instantly, be swallowed, or be
/// accumulated into a [CompositeSinkException] while still guaranteeing delivery
/// to the remaining healthy sinks.
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

  /// Creates a new composite event sink that forwards events to the provided [sinks].
  ///
  /// The [throwOnClosed] parameter controls whether operations throw a [StateError]
  /// after [close] has been called (defaults to `false` for silent ignore).
  ///
  /// The [exceptionStrategy] controls how exceptions thrown by child sinks are handled
  /// (defaults to [ExceptionStrategy.failFast]).
  ///
  /// Throws an [ArgumentError] if [sinks] is null (handled by standard Dart null safety,
  /// but an empty iterable is permitted).
  CompositeEventSink(
    Iterable<EventSink<T>> sinks, {
    bool throwOnClosed = false,
    ExceptionStrategy exceptionStrategy = ExceptionStrategy.failFast,
  })  : _sinks = sinks.toList(),
        _throwOnClosed = throwOnClosed,
        _exceptionStrategy = exceptionStrategy;

  /// Forwards the provided [data] to all child sinks.
  ///
  /// If this composite sink is already closed, this operation either throws a
  /// [StateError] (if `throwOnClosed` was set to `true` during construction)
  /// or is silently ignored.
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

  /// Closes this composite sink and forwards the close call to all child sinks.
  ///
  /// Once closed, further calls to [add], [addError], or [close] will be
  /// rejected (either throwing a [StateError] or being ignored, depending on
  /// `throwOnClosed`).
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

  /// Forwards the provided [error] and optional [stackTrace] to all child sinks.
  ///
  /// If this composite sink is already closed, this operation either throws a
  /// [StateError] (if `throwOnClosed` was set to `true` during construction)
  /// or is silently ignored.
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
