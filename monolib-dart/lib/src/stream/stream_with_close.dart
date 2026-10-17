/// Provides [StreamWithClose], an architectural wrapper that binds a [Stream]
/// to the lifecycle of its underlying [StreamSubscription]s and [StreamController].
library;

import 'dart:async';

import 'package:monolib_dart/src/general/on_list.dart';

/// A composite disposable wrapper that tightly binds a generated [Stream] to
/// the underlying infrastructure backing it.
///
/// Within complex asynchronous systems (like multi-source multiplexers or pipelines
/// pulling from external resources), exposing a bare [Stream] leaves a critical lifecycle
/// ambiguity: how does the consumer command the producer to tear down its underlying
/// sockets, timers, or [StreamSubscription]s once consumption finishes?
///
/// [StreamWithClose] addresses this architectural gap. By bundling the observable
/// [stream] together with its source [controller] and internal [subscriptions], it
/// guarantees that consumers have a standardized, zero-cost mechanism (`.close()`)
/// to safely dismantle the entire pipeline, preventing zombie listeners and resource leaks.
///
/// Realistic Usage Example:
/// ```dart
/// StreamWithClose<int> createPolledStream() {
///   final controller = StreamController<int>();
///   final timerSub = Stream.periodic(Duration(seconds: 1)).listen((i) {
///     controller.add(i);
///   });
///
///   return StreamWithClose(
///     stream: controller.stream,
///     subscriptions: [timerSub],
///     controller: controller,
///   );
/// }
///
/// final closable = createPolledStream();
/// // ... consume closable.stream ...
/// await closable.close(); // Cleans up the timer and controller
/// ```
extension type const StreamWithClose<T>._(
    ({
      Stream<T> stream,
      List<StreamSubscription> subscriptions,
      StreamController<T> controller,
    }) _data) {
  /// Creates a [StreamWithClose] that pairs a public [stream] with its internal
  /// [subscriptions] and [controller].
  ///
  /// The [stream] is the observable output provided to consumers. The
  /// [subscriptions] list contains any intermediate listeners that feed the
  /// pipeline, and the [controller] is the sink orchestrating the [stream].
  /// All of these are guaranteed to be cleaned up when [close] is invoked.
  StreamWithClose({
    required Stream<T> stream,
    required List<StreamSubscription> subscriptions,
    required StreamController<T> controller,
  }) : this._((
          stream: stream,
          subscriptions: subscriptions,
          controller: controller,
        ));

  /// The observable stream of data that consumers can listen to.
  ///
  /// This [Stream] is structurally tied to the underlying components. Once
  /// [close] is called, no further events will be emitted.
  Stream<T> get stream => _data.stream;

  /// Safely tears down the stream pipeline by terminating all internal components.
  ///
  /// It uses [drainMap] (from `OnList`) to destructively iterate over the
  /// underlying [subscriptions] and cancel each one, and then closes the main
  /// [controller]. It returns a [Future] that completes when all teardown
  /// operations have finished.
  ///
  /// Calling this method prevents resource leaks, such as dangling periodic timers
  /// or unclosed network sockets backing the [stream].
  Future<void> close() {
    return _data.subscriptions.drainMap((s) => s.cancel()).followedBy([
      _data.controller.close(),
    ]).wait;
  }
}
