import 'dart:async';

/// An architectural utility stream that caches a single synchronous [value] and acts
/// as a broadcast stream, instantly yielding its cached value to any new listeners.
///
/// Within the stream pipeline architecture, this class bridges the gap between
/// static, readily-available state and asynchronous, event-driven consumers
/// (such as `StreamBuilder` in Flutter or downstream stream transformations).
/// It bypasses the complexity of a `BehaviorSubject` or a stateful `StreamController`
/// when the underlying data is immutable and only a single emission is ever required
/// per listener.
///
/// Because it overrides [isBroadcast] to `true`, multiple disparate components
/// can subscribe to this stream independently without triggering the "Stream has
/// already been listened to" `StateError`. Each new listener will independently
/// receive the [value].
///
/// Example:
/// ```dart
/// // Useful in testing or fallback scenarios where an API requires a Stream
/// // but the value is already known synchronously.
/// Stream<String> getGreetingStream() {
///   return SingleValueCachingStream('Hello, World!');
/// }
///
/// final stream = getGreetingStream();
/// stream.listen(print); // Prints: Hello, World!
/// stream.listen(print); // Prints: Hello, World!
/// ```
class SingleValueCachingStream<T> extends Stream<T> {
  /// The underlying synchronously accessible state cached by this stream.
  ///
  /// This [value] is emitted exactly once to every new subscriber that
  /// attaches to this stream via [listen].
  final T value;

  /// Creates a new broadcast stream that caches and emits the provided [value].
  ///
  /// The [value] is retained in memory for the lifetime of this stream
  /// and is dispatched asynchronously to each subscriber upon listening.
  const SingleValueCachingStream(this.value);

  /// Indicates that this stream supports multiple independent listeners.
  ///
  /// Overriding this to `true` allows the stream to be consumed by multiple
  /// clients (like multiple UI widgets or transformations) simultaneously
  /// without throwing a state error.
  @override
  bool get isBroadcast => true;

  /// Subscribes to this stream to receive the cached [value].
  ///
  /// Under the hood, this delegates to [Stream.value] for each subscription,
  /// ensuring that the [value] is emitted asynchronously as a data event to
  /// [onData]. Afterwards, the stream will immediately close, triggering [onDone].
  ///
  /// - [onData]: Invoked with the cached [value].
  /// - [onError]: Handlers for stream errors (though this stream only emits data).
  /// - [onDone]: Invoked immediately after [onData] is emitted.
  /// - [cancelOnError]: Whether the subscription should be cancelled if an error occurs.
  @override
  StreamSubscription<T> listen(
    void Function(T event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) =>
      Stream.value(value).listen(
        onData,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      );
}
