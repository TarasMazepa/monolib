/// Provides [StreamWhereTypeExtension] for filtering stream events by runtime type.
library;

import 'dart:async';

/// An extension on [Stream] that provides the architectural utility [whereType]
/// for safely and fluently filtering asynchronous events based on their runtime type.
///
/// This eliminates the need for chained `where((e) => e is T).cast<T>()` operations,
/// offering a more concise, type-safe API for stream transformation in reactive pipelines.
extension StreamWhereTypeExtension<T> on Stream<T> {
  /// Transforms this stream by filtering elements to only those matching the type [R].
  ///
  /// This acts as a streamlined [StreamTransformer] that inspects each incoming
  /// event from the source stream. If the event is an instance of [R], it is
  /// seamlessly emitted down the pipeline with the correct static type [R].
  /// Non-matching events are silently ignored and dropped from the stream.
  ///
  /// **Example:**
  /// ```dart
  /// final mixedStream = Stream<Object>.fromIterable([1, 'two', 3.0, 4, 'five']);
  ///
  /// // Extracts only the integer elements.
  /// final intStream = mixedStream.whereType<int>();
  ///
  /// await for (final number in intStream) {
  ///   print(number); // Outputs: 1, 4
  /// }
  /// ```
  ///
  /// Returns a new [Stream] emitting only the elements of type [R].
  Stream<R> whereType<R>() {
    return transform(
      StreamTransformer<T, R>.fromHandlers(
        handleData: (event, sink) {
          if (event is R) {
            sink.add(event); // Implicitly casts to R
          }
        },
      ),
    );
  }
}
