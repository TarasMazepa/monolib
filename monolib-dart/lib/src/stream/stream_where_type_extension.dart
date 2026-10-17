/// Provides [StreamWhereTypeExtension] for filtering stream events by runtime type.
library;

import 'dart:async';

/// A type-safe filtering mechanism for reactive stream pipelines.
///
/// When consuming heterogeneous data streams (like event buses emitting mixed subclasses,
/// or raw parsers yielding dynamic objects), filtering elements by their exact runtime type
/// is a fundamental requirement. Dart's standard library forces developers to chain `.where((e) => e is T).cast<T>()`
/// to achieve this, leading to unnecessary intermediate wrapper allocations and boilerplate.
///
/// This extension provides a single-pass architectural utility, [whereType], that
/// inherently fuses the type-check and the static downcast, silently dropping invalid
/// elements without triggering downstream null-safety errors.
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
