/// Provides safe terminal operations for Dart [Stream]s.
library;

import 'dart:async';

/// An architectural extension on Dart's [Stream] providing safe, exception-free
/// terminal value extraction.
///
/// In Dart's standard library, operations like [Stream.last] aggressively throw
/// a [StateError] if the stream emits no elements before closing. This often
/// forces developers to wrap stream resolution in verbose `try-catch` blocks
/// or implement custom reduction logic when dealing with asynchronous sources
/// that might legitimately be empty (e.g., filtered event buses, conditional
/// socket reads).
///
/// [OnStream] introduces safe alternatives that gracefully resolve to `null`
/// when a stream completes without emitting usable data, aligning asynchronous
/// streams with Dart's modern null-safety paradigms. By relying on a raw
/// [StreamSubscription] and a [Completer], these methods intentionally avoid
/// the microtask overhead associated with `await for` loops and [StreamIterator].
extension OnStream<T> on Stream<T> {
  /// Asynchronously resolves to the final element emitted by the stream,
  /// gracefully returning `null` if the stream closes empty.
  ///
  /// Unlike [Stream.last], which throws a [StateError] when the stream contains
  /// no elements, this getter provides a safe, exception-free mechanism for
  /// extracting the terminal value of an asynchronous sequence. If the stream
  /// emits an error, the returned [Future] will complete with that error and
  /// the internal subscription is immediately cancelled.
  ///
  /// ### Example
  /// ```dart
  /// final stream = Stream.fromIterable([1, 2, 3]);
  /// final lastItem = await stream.lastOrNull; // Resolves to 3
  ///
  /// final emptyStream = Stream<int>.empty();
  /// final noItem = await emptyStream.lastOrNull; // Resolves to null
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

  /// Asynchronously resolves to the final non-null value produced by applying
  /// [mapper] to the stream's elements.
  ///
  /// This method acts as a unified mapping, filtering, and reduction pipeline.
  /// As elements arrive, they are passed to the [mapper]. If [mapper] returns
  /// a non-null value, it overwrites the previously tracked result. When the
  /// stream completes, the most recent non-null result is returned.
  ///
  /// This avoids the overhead of chaining multiple stream transformers (like
  /// `.map().where().lastOrNull`) by performing the transformation and
  /// state-tracking in a single pass.
  ///
  /// Returns `null` if the stream is empty, or if every element evaluated by
  /// [mapper] returned `null`. Any stream errors immediately cancel processing
  /// and are forwarded to the returned [Future].
  ///
  /// ### Example
  /// ```dart
  /// final stream = Stream.fromIterable([1, 2, 3, 4, 5]);
  /// // Find the last even number, multiplied by 10.
  /// final result = await stream.mappedLastOrNull(
  ///   (e) => e.isEven ? (e * 10) : null,
  /// ); // Resolves to 40
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
