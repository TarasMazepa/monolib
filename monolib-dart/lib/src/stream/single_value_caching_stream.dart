import 'dart:async';

/// A broadcast [Stream] that caches a single synchronous [value] and emits it
/// to each new listener before closing.
///
/// Because [isBroadcast] is `true`, multiple listeners can subscribe
/// independently and each will receive [value] followed by a done event.
///
/// Example:
/// ```dart
/// Stream<String> getGreetingStream() {
///   return const SingleValueCachingStream('Hello, World!');
/// }
///
/// final stream = getGreetingStream();
/// stream.listen(print); // Prints: Hello, World!
/// stream.listen(print); // Prints: Hello, World!
/// ```
class SingleValueCachingStream<T> extends Stream<T> {
  /// The cached value emitted to every subscriber of this stream.
  final T value;

  /// Creates a broadcast stream that emits [value] to each listener.
  const SingleValueCachingStream(this.value);

  /// Whether this stream is a broadcast stream (always `true`).
  @override
  bool get isBroadcast => true;

  /// Subscribes to this stream and asynchronously emits the cached [value]
  /// followed by a done event.
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
