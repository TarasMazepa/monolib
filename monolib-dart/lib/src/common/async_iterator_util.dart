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
/// the next item). If [items] is an [Iterable], it iterates synchronously and
/// returns `null` unless [processItem] returns a [Future], in which case it
/// awaits remaining elements asynchronously.
///
/// Returns a [Future] if asynchronous work was awaited (or if [items] is a
/// [Stream]), or `null` if traversal completed entirely synchronously.
///
/// Throws an [ArgumentError] if [items] is neither a [Stream] nor an [Iterable].
///
/// Example:
/// ```dart
/// FutureOr<void> encode(Object items, FutureOr<void> Function(dynamic) write) {
///   return iterateStreamOrIterable(items, (item) {
///     write(item);
///   });
/// }
/// ```
FutureOr<void> iterateStreamOrIterable(
  Object items,
  FutureOr<void> Function(dynamic) processItem, {
  void Function()? onStreamItemDone,
}) {
  switch (items) {
    case Stream stream:
      return () async {
        await for (final item in stream) {
          final result = processItem(item);
          if (result is Future) {
            await result;
          }
          onStreamItemDone?.call();
        }
      }();

    case Iterable iterable:
      final iterator = iterable.iterator;
      while (iterator.moveNext()) {
        final result = processItem(iterator.current);
        if (result is Future) {
          return () async {
            await result;
            while (iterator.moveNext()) {
              final nextResult = processItem(iterator.current);
              if (nextResult is Future) {
                await nextResult;
              }
            }
          }();
        }
      }
      return null;

    default:
      throw ArgumentError(
        'The "items" parameter must be an Iterable or a Stream.',
      );
  }
}
