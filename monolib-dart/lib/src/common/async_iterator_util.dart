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
/// Returns `null` if [items] is an [Iterable] whose elements were all processed
/// synchronously, or a [Future] if asynchronous processing was required.
///
/// Throws an [ArgumentError] if [items] is neither a [Stream] nor an [Iterable].
///
/// Example:
/// ```dart
/// FutureOr<void> encode(Object items, FutureOr<void> Function(dynamic) write) {
///   final future = iterateStreamOrIterable(items, (item) {
///     write(item);
///   });
///   if (future != null) return future;
/// }
/// ```
Future<void>? iterateStreamOrIterable(
  Object items,
  FutureOr<void> Function(dynamic) processItem, {
  void Function()? onStreamItemDone,
}) {
  switch (items) {
    case Stream stream:
      return _iterateStream(stream, processItem, onStreamItemDone);

    case Iterable iterable:
      final iterator = iterable.iterator;
      while (iterator.moveNext()) {
        final result = processItem(iterator.current);
        if (result is Future) {
          return _resumeIterable(iterator, result, processItem);
        }
      }
      return null;

    default:
      throw ArgumentError(
        'The "items" parameter must be an Iterable or a Stream.',
      );
  }
}

Future<void> _iterateStream(
  Stream stream,
  FutureOr<void> Function(dynamic) processItem,
  void Function()? onStreamItemDone,
) async {
  await for (final item in stream) {
    final result = processItem(item);
    if (result is Future) {
      await result;
    }
    onStreamItemDone?.call();
  }
}

Future<void> _resumeIterable(
  Iterator iterator,
  Future pendingFuture,
  FutureOr<void> Function(dynamic) processItem,
) async {
  await pendingFuture;
  while (iterator.moveNext()) {
    final result = processItem(iterator.current);
    if (result is Future) {
      await result;
    }
  }
}
