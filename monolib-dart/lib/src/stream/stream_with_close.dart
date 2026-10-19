import 'dart:async';

import 'package:monolib_dart/src/general/on_list.dart';

/// A wrapper that pairs a [Stream] with the [StreamSubscription]s and
/// [StreamController] backing it so they can be closed together.
///
/// Calling [close] cancels all underlying subscriptions and closes the
/// controller in a single operation.
///
/// Example:
/// ```dart
/// StreamWithClose<int> createPolledStream() {
///   final controller = StreamController<int>();
///   final timerSub = Stream.periodic(const Duration(seconds: 1)).listen((i) {
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
/// await closable.close(); // Cancels timerSub and closes controller
/// ```
extension type const StreamWithClose<T>._(
    ({
      Stream<T> stream,
      List<StreamSubscription> subscriptions,
      StreamController<T> controller,
    }) _data) {
  /// Creates a [StreamWithClose] bundling [stream] with its backing
  /// [subscriptions] and [controller].
  StreamWithClose({
    required Stream<T> stream,
    required List<StreamSubscription> subscriptions,
    required StreamController<T> controller,
  }) : this._((
          stream: stream,
          subscriptions: subscriptions,
          controller: controller,
        ));

  /// The output [Stream] exposed to consumers.
  Stream<T> get stream => _data.stream;

  /// Cancels all backing subscriptions (via [OnList.drainMap]) and closes the
  /// underlying [StreamController].
  ///
  /// Returns a [Future] that completes when all cancellations and the
  /// controller close operation have finished.
  Future<void> close() {
    return _data.subscriptions.drainMap((s) => s.cancel()).followedBy([
      _data.controller.close(),
    ]).wait;
  }
}
