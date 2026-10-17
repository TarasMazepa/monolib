/// Fault-tolerant broadcasting utilities for collections of [StreamController]s.
///
/// This library provides extension methods to safely dispatch data and error
/// events to multiple controllers simultaneously, allowing customization of
/// exception handling strategies via [ExceptionStrategy].
library;

import 'dart:async';
import 'package:monolib_dart/src/stream/composite_event_sink/exception_strategy.dart';

/// An architectural utility that enables safe multiplexing of events across
/// multiple [StreamController] instances.
///
/// When managing custom broadcast architectures (like list-backed subscriber pools
/// or dynamic event bus routing), individual stream controllers may have been closed
/// or otherwise become unable to accept new events. This extension abstracts away the
/// need to manually inspect each controller's state or wrap individual dispatch
/// operations in `try-catch` blocks.
///
/// It acts as a resilient fan-out mechanism. By default, it swallows exceptions
/// (like [StateError] from closed controllers), but this can be customized using
/// an [ExceptionStrategy].
extension OnIterableOfStreamControllers<T> on Iterable<StreamController<T>> {
  /// Safely dispatches the given data [event] to all stream controllers in this collection.
  ///
  /// Iterates through the collection and invokes [StreamController.add] on each element.
  /// The [strategy] controls how exceptions thrown by a controller are handled
  /// (defaults to [ExceptionStrategy.swallow]).
  ///
  /// ```dart
  /// final subscribers = <StreamController<String>>[
  ///   StreamController<String>(),
  ///   StreamController<String>()..close(),
  ///   StreamController<String>(),
  /// ];
  ///
  /// // Successfully dispatches 'Update' to the first and third controllers.
  /// // The StateError from the second (closed) controller is swallowed.
  /// subscribers.onEachAdd('Update');
  /// ```
  void onEachAdd(T event,
      {ExceptionStrategy strategy = ExceptionStrategy.swallow}) {
    strategy.dispatch(this, (sink) => sink.add(event));
  }

  /// Safely dispatches an [error] and an optional [stackTrace] to all stream controllers
  /// in this collection.
  ///
  /// Iterates through the collection and invokes [StreamController.addError] on each element.
  /// The [strategy] controls how exceptions thrown by a controller are handled
  /// (defaults to [ExceptionStrategy.swallow]).
  ///
  /// ```dart
  /// final subscribers = <StreamController<int>>[
  ///   StreamController<int>(),
  /// ];
  ///
  /// try {
  ///   throw FormatException('Invalid data format');
  /// } catch (e, st) {
  ///   // Safely forwards the exception and stack trace to all active subscribers.
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
