/// Fault-tolerant broadcasting utilities for collections of [StreamController]s.
///
/// This library provides extension methods to safely dispatch data and error
/// events to multiple controllers simultaneously, allowing customization of
/// exception handling strategies via [ExceptionStrategy].
library;

import 'dart:async';
import 'package:monolib_dart/src/stream/composite_event_sink/exception_strategy.dart';

/// A resilient broadcast multiplexer for manually managed subscriber pools.
///
/// Within custom reactive architectures (like dynamic event buses, publisher-subscriber
/// patterns, or list-backed state observers), developers frequently maintain an
/// `Iterable<StreamController>` representing connected clients. Directly iterating
/// and invoking `add()` on these controllers is brittle: if any single downstream
/// consumer has concurrently closed their connection, standard Dart streams throw
/// an unhandled [StateError], immediately crashing the entire broadcast loop and
/// leaving subsequent clients unnotified.
///
/// This extension resolves this architectural fragility by providing safe,
/// transactional fan-out methods. It abstracts away manual state inspection
/// (`!controller.isClosed`) and delegates error handling to an [ExceptionStrategy],
/// ensuring guaranteed delivery topologies even across mixed-state subscriber pools.
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
  void onEachAdd(
    T event, {
    ExceptionStrategy strategy = ExceptionStrategy.swallow,
  }) {
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
