import 'dart:async';

/// Iterates over either a [Stream] or an [Iterable], applying the
/// [processItem] callback to each element sequentially.
///
/// This function allows encoders (such as CSV and JSONL) to accept either
/// streaming data sources or in-memory collections through a single parameter
/// without duplicating traversal logic.
///
/// If [items] is a [Stream], this function uses `await for` to lazily process
/// items as they are yielded, optionally invoking [onStreamItemDone] after each
/// stream event is processed (e.g., to flush buffered output before awaiting
/// the next item). If [items] is an [Iterable], it iterates synchronously while
/// awaiting [processItem] when a [Future] is returned.
///
/// Throws an [ArgumentError] if [items] is neither a [Stream] nor an [Iterable].
///
/// Example:
/// ```dart
/// Future<void> encode(Object items, Future<void> Function(dynamic) write) async {
///   await iterateStreamOrIterable(items, (item) async {
///     await write(item);
///   });
/// }
/// ```
Future<void> iterateStreamOrIterable(
  Object items,
  FutureOr<void> Function(dynamic) processItem, {
  void Function()? onStreamItemDone,
}) async {
  switch (items) {
    case Stream stream:
      await for (final item in stream) {
        final result = processItem(item);
        if (result is Future) {
          await result;
        }
        onStreamItemDone?.call();
      }
      break;

    case Iterable iterable:
      for (final item in iterable) {
        final result = processItem(item);
        if (result is Future) {
          await result;
        }
      }
      break;

    default:
      throw ArgumentError(
        'The "items" parameter must be an Iterable or a Stream.',
      );
  }
}
