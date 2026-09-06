import 'dart:async';

/// A composite event sink that forwards events to multiple target sinks.
///
/// This class is useful when you have a single source of events but need to
/// broadcast those events to multiple destinations (sinks). It implements
/// [EventSink] and distributes [add], [addError], and [close] calls to all
/// provided child sinks.
class CompositeEventSink<T> implements EventSink<T> {
  final List<EventSink<T>> _sinks;
  bool _closed = false;

  /// Creates a new composite event sink that forwards events to the provided [sinks].
  CompositeEventSink(Iterable<EventSink<T>> sinks) : _sinks = sinks.toList();

  @override
  void add(T data) {
    if (_closed) return;
    for (final sink in _sinks) {
      sink.add(data);
    }
  }

  @override
  void close() {
    if (_closed) return;
    _closed = true;
    for (final sink in _sinks) {
      sink.close();
    }
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    if (_closed) return;
    for (final sink in _sinks) {
      sink.addError(error, stackTrace);
    }
  }
}
