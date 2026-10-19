import 'dart:async';

/// Iterates over either a [Stream] or an [Iterable], applying the asynchronous
/// [processItem] callback to each element sequentially.
///
/// This function allows encoders (such as CSV and JSONL) to accept either
/// streaming data sources or in-memory collections through a single parameter
/// without duplicating traversal logic.
///
/// If [items] is a [Stream], this function uses `await for` to lazily process
/// items as they are yielded. If [items] is an [Iterable], it iterates
/// synchronously while awaiting [processItem] for each element.
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
  Future<void> Function(dynamic) processItem,
) async {
  switch (items) {
    case Stream stream:
      await for (final item in stream) {
        await processItem(item);
      }
      break;

    case Iterable iterable:
      for (final item in iterable) {
        await processItem(item);
      }
      break;

    default:
      throw ArgumentError(
        'The "items" parameter must be an Iterable or a Stream.',
      );
  }
}
