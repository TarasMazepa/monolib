import 'dart:async';

/// Provides utility methods on [Future]s that resolve to an [EventSink].
///
/// This extension enables seamless, synchronous data pushing to a sink that
/// is still undergoing asynchronous initialization. It bridges the timing gap
/// between a synchronous producer that is ready to emit data and an asynchronous
/// destination that is not yet fully connected or opened (e.g., a file writer,
/// a database connection, or a network stream).
extension FutureEventSinkExtension<T> on Future<EventSink<T>> {
  /// Unwraps the [Future] into a synchronous [EventSink] that immediately accepts
  /// events, buffering them in memory until the underlying sink resolves.
  ///
  /// This method is particularly useful in architectural scenarios where an API
  /// requires returning a synchronous sink to a caller, but the actual destination
  /// sink must be initialized asynchronously.
  ///
  /// When called, it immediately returns a proxy [EventSink]. Any data ([EventSink.add]),
  /// errors ([EventSink.addError]), or close ([EventSink.close]) operations invoked on
  /// this proxy are buffered by an internal [StreamController]. Once the [Future]
  /// completes successfully, all buffered events are sequentially forwarded into the
  /// resolved sink.
  ///
  /// If the [Future] fails with an error, the proxy sink is safely closed to drop
  /// any further incoming events, and the future's error is forwarded to the
  /// current [Zone] via [Zone.handleUncaughtError] to ensure it is not silently swallowed.
  ///
  /// ```dart
  /// // Example: Asynchronously opening a connection, but providing a synchronous sink
  /// // to a producer immediately.
  /// Future<EventSink<List<int>>> openConnectionAsync() async {
  ///   await Future<void>.delayed(const Duration(seconds: 1)); // Simulate async setup
  ///   return StreamController<List<int>>().sink;
  /// }
  ///
  /// void processData() {
  ///   // The producer gets a sink right away and can start writing,
  ///   // completely oblivious to the async setup.
  ///   final EventSink<List<int>> sink = openConnectionAsync().unwrap();
  ///
  ///   sink.add([1, 2, 3]);
  ///   sink.addError(Exception('An error occurred'));
  ///   sink.close();
  /// }
  /// ```
  ///
  /// Returns a proxy [EventSink] that buffers and forwards to the underlying sink.
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
