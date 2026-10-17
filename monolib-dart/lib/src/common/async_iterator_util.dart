/// Provides [iterateStreamOrIterable], an architectural utility for polymorphic asynchronous iteration.
library;

import 'dart:async';

/// Iterates over either a [Stream] or an [Iterable], applying the asynchronous
/// [processItem] callback to each element sequentially.
///
/// This utility exists to unify processing loops in encoders (such as CSV and
/// JSONL) which need to accept heterogeneous collections from consumers (often
/// passed as `Object items` or `dynamic`) without requiring the consumer to
/// differentiate between streaming data sources and static collections.
///
/// By providing a single iteration strategy, this function ensures that memory-
/// efficient streaming and synchronous batch processing share the same async
/// traversal logic, simplifying higher-level data encoding routines like
/// `encodeBatchAsync`, `csvEncodeAsync`, and `jsonlEncodeAsync`.
///
/// If [items] is a [Stream], this function uses `await for` to lazily process
/// items as they are yielded. If [items] is an [Iterable], it iterates synchronously
/// but still awaits the [processItem] callback for each element.
///
/// Throws an [ArgumentError] if [items] is neither a [Stream] nor an [Iterable].
///
/// Example usage within an encoder:
/// ```dart
/// Future<void> encode(Object items, Future<void> Function(dynamic) write) async {
///   await iterateStreamOrIterable(items, (item) async {
///     // Handle Future unboxing if necessary, then process
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
