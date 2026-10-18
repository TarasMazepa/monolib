import 'dart:async';

/// Extension on [Future] of [EventSink] that exposes a synchronous proxy
/// [EventSink] while the underlying sink is still initializing.
extension FutureEventSinkExtension<T> on Future<EventSink<T>> {
  /// Unwraps this [Future] into a synchronous proxy [EventSink] that buffers
  /// events in memory until the underlying sink completes.
  ///
  /// Any calls to [EventSink.add], [EventSink.addError], or [EventSink.close]
  /// on the returned proxy sink are buffered by an internal [StreamController].
  /// When this [Future] resolves, all buffered and subsequent events are
  /// forwarded to the resolved [EventSink].
  ///
  /// If this [Future] completes with an error, the proxy sink is closed and
  /// the error is reported to [Zone.current] via [Zone.handleUncaughtError].
  ///
  /// Returns a proxy [EventSink] that buffers and forwards events to the
  /// resolved sink.
  ///
  /// Example:
  /// ```dart
  /// Future<EventSink<List<int>>> openConnectionAsync() async {
  ///   await Future<void>.delayed(const Duration(seconds: 1));
  ///   return StreamController<List<int>>().sink;
  /// }
  ///
  /// void processData() {
  ///   final EventSink<List<int>> sink = openConnectionAsync().unwrap();
  ///   sink.add([1, 2, 3]);
  ///   sink.addError(Exception('An error occurred'));
  ///   sink.close();
  /// }
  /// ```
  EventSink<T> unwrap() {
    final controller = StreamController<T>(sync: true);

    then((resolvedSink) {
      controller.stream.listen(
        resolvedSink.add,
        onError: resolvedSink.addError,
        onDone: resolvedSink.close,
      );
    }).catchError((Object error, StackTrace stackTrace) {
      controller.close();
      Zone.current.handleUncaughtError(error, stackTrace);
    });

    return controller.sink;
  }
}
