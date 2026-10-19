import 'dart:async';

/// Extension on [Stream] that provides null-safe terminal operations for
/// retrieving the last emitted element.
extension OnStream<T> on Stream<T> {
  /// Completes with the last element emitted by this stream, or `null` if the
  /// stream closes without emitting any elements.
  ///
  /// Unlike [Stream.last], which throws a [StateError] when the stream is
  /// empty, this getter completes with `null`. If the stream emits an error,
  /// the subscription is cancelled and the returned [Future] completes with
  /// that error.
  ///
  /// Example:
  /// ```dart
  /// final stream = Stream.fromIterable([1, 2, 3]);
  /// final lastItem = await stream.lastOrNull; // 3
  ///
  /// final emptyStream = Stream<int>.empty();
  /// final noItem = await emptyStream.lastOrNull; // null
  /// ```
  Future<T?> get lastOrNull {
    final completer = Completer<T?>();
    T? result;

    listen(
      (event) {
        result = event;
      },
      onError: completer.completeError,
      onDone: () {
        completer.complete(result);
      },
      cancelOnError: true,
    );

    return completer.future;
  }

  /// Completes with the last non-null value returned by [mapper] for elements
  /// of this stream, or `null` if no element produces a non-null result.
  ///
  /// Each emitted event is passed to [mapper]; whenever [mapper] returns a
  /// non-null value, it replaces the latest tracked result. If the stream
  /// emits an error, the subscription is cancelled and the returned [Future]
  /// completes with that error.
  ///
  /// Example:
  /// ```dart
  /// final stream = Stream.fromIterable([1, 2, 3, 4, 5]);
  /// final result = await stream.mappedLastOrNull(
  ///   (e) => e.isEven ? (e * 10) : null,
  /// ); // 40
  /// ```
  Future<R?> mappedLastOrNull<R>(R? Function(T) mapper) {
    final completer = Completer<R?>();
    R? result;

    listen(
      (event) {
        final mapped = mapper(event);
        if (mapped != null) {
          result = mapped;
        }
      },
      onError: completer.completeError,
      onDone: () {
        completer.complete(result);
      },
      cancelOnError: true,
    );

    return completer.future;
  }
}
