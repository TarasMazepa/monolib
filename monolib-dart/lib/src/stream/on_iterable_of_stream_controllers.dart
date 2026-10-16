/// Fault-tolerant broadcasting utilities for collections of [StreamController]s.
///
/// This library provides extension methods to safely dispatch data and error
/// events to multiple controllers simultaneously, swallowing exceptions caused
/// by invalid controller states (such as attempting to add events to a closed controller).
library;

import 'dart:async';

/// An architectural utility that enables safe multiplexing of events across
/// multiple [StreamController] instances.
///
/// When managing custom broadcast architectures (like list-backed subscriber pools
/// or dynamic event bus routing), individual stream controllers may have been closed
/// or otherwise become unable to accept new events. This extension abstracts away the
/// need to manually inspect each controller's state or wrap individual dispatch
/// operations in `try-catch` blocks.
///
/// It acts as a resilient fan-out mechanism, guaranteeing that a failure to dispatch
/// to one controller (e.g., resulting in a [StateError]) does not prevent remaining
/// controllers from receiving the event.
extension OnIterableOfStreamControllers<T> on Iterable<StreamController<T>> {
  /// Safely dispatches the given data [event] to all stream controllers in this collection.
  ///
  /// Iterates through the collection and invokes [StreamController.add] on each element.
  /// If a controller throws an exception (such as a [StateError] because it is closed),
  /// the exception is gracefully ignored and iteration continues to the next controller.
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
  void onEachAdd(T event) {
    for (final listener in this) {
      try {
        listener.add(event);
      } catch (_) {
        // ignore
      }
    }
  }

  /// Safely dispatches an [error] and an optional [stackTrace] to all stream controllers
  /// in this collection.
  ///
  /// Iterates through the collection and invokes [StreamController.addError] on each element.
  /// Any exceptions thrown during dispatch (e.g., if a controller is closed) are
  /// gracefully ignored, allowing the remaining valid controllers to receive the error.
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
  void onEachAddError(Object error, [StackTrace? stackTrace]) {
    for (final listener in this) {
      try {
        listener.addError(error, stackTrace);
      } catch (_) {
        // ignore
      }
    }
  }
}
