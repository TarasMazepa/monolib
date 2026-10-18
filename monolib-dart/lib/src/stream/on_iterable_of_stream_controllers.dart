import 'dart:async';
import 'package:monolib_dart/src/stream/composite_event_sink/exception_strategy.dart';

/// Extension on [Iterable] of [StreamController] that broadcasts data and error
/// events across all controllers using a configurable [ExceptionStrategy].
extension OnIterableOfStreamControllers<T> on Iterable<StreamController<T>> {
  /// Dispatches [event] to every [StreamController] in this iterable.
  ///
  /// Calls [StreamController.add] on each controller, handling any synchronous
  /// exceptions with [strategy] (defaults to [ExceptionStrategy.swallow]).
  ///
  /// Example:
  /// ```dart
  /// final subscribers = <StreamController<String>>[
  ///   StreamController<String>(),
  ///   StreamController<String>()..close(),
  ///   StreamController<String>(),
  /// ];
  ///
  /// // Dispatches 'Update' to the open controllers while swallowing the
  /// // StateError from the closed controller.
  /// subscribers.onEachAdd('Update');
  /// ```
  void onEachAdd(
    T event, {
    ExceptionStrategy strategy = ExceptionStrategy.swallow,
  }) {
    strategy.dispatch(this, (sink) => sink.add(event));
  }

  /// Dispatches [error] and optional [stackTrace] to every [StreamController]
  /// in this iterable.
  ///
  /// Calls [StreamController.addError] on each controller, handling any
  /// synchronous exceptions with [strategy] (defaults to
  /// [ExceptionStrategy.swallow]).
  ///
  /// Example:
  /// ```dart
  /// final subscribers = <StreamController<int>>[
  ///   StreamController<int>(),
  /// ];
  ///
  /// try {
  ///   throw FormatException('Invalid data format');
  /// } catch (e, st) {
  ///   subscribers.onEachAddError(e, st);
  /// }
  /// ```
  void onEachAddError(
    Object error, [
    StackTrace? stackTrace,
    ExceptionStrategy strategy = ExceptionStrategy.swallow,
  ]) {
    strategy.dispatch(this, (sink) => sink.addError(error, stackTrace));
  }
}
