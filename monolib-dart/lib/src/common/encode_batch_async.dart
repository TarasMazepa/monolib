/// A shared utility for asynchronously encoding streamed data batches.
library;

import 'dart:async';

import 'package:monolib_dart/src/common/async_iterator_util.dart';
import 'package:monolib_dart/src/common/with_lazy_string_sink.dart';

/// A generic architectural foundation for asynchronous chunk-based data encoders.
///
/// This function unifies the core workflow of streaming encoders (such as
/// [csvEncodeBatchAsync] and [jsonlEncodeBatchAsync]) by abstracting two common
/// infrastructural needs:
///
/// 1. **Resource Lifecycle Management:** It delegates manual sink validation,
///    initialization, and safe tear-down logic to [withLazyStringSink]. This ensures
///    that a file or buffer is only lazily initialized when data actually arrives,
///    preventing empty outputs for zero-element streams.
/// 2. **Iteration and Dispatch:** It processes the inbound [batches] stream using
///    [iterateStreamOrIterable], sequentially passing each aggregated chunk to the
///    domain-specific [encodeAsync] callback.
///
/// The consumer API expects either an existing [sink] to append data to, or a
/// [sinkProvider] factory. The target sink is lazily initialized and passed to
/// [encodeAsync] alongside each chunk.
///
/// - [batches]: A stream of data chunks (typically `List<T>`) representing aggregated
///   input to be sequentially processed.
/// - [encodeAsync]: A domain-specific callback (e.g., CSV or JSONL encoding logic)
///   invoked for each batch, responsible for writing the formatted string data into
///   the `sink`.
/// - [sink]: An already instantiated and caller-managed target sink. If provided,
///   the caller is responsible for eventually closing it.
/// - [sinkProvider]: A factory function that lazily instantiates the target sink.
///   If provided, this function takes ownership and ensures the sink is closed
///   upon completion.
///
/// **Note:** Exactly one of [sink] or [sinkProvider] must be provided.
///
/// Example:
/// ```dart
/// // Internal usage demonstrating how domain encoders leverage this foundation:
/// Future<void> myCustomFormatEncodeBatchAsync<T>({
///   required Stream<List<T>> batches,
///   StringSink? sink,
///   StringSink Function()? sinkProvider,
/// }) {
///   return encodeBatchAsync(
///     batches: batches,
///     encodeAsync: (items, targetSink) =>
///         myCustomFormatEncodeAsync(items: items, sink: targetSink),
///     sink: sink,
///     sinkProvider: sinkProvider,
///   );
/// }
/// ```
Future<void> encodeBatchAsync<T>({
  required Stream<List<T>> batches,
  required Future<void> Function(Object items, StringSink sink) encodeAsync,
  StringSink? sink,
  StringSink Function()? sinkProvider,
}) {
  return withLazyStringSink(
    sink: sink,
    sinkProvider: sinkProvider,
    action: (getSink) async {
      await iterateStreamOrIterable(batches, (dynamic batch) async {
        await encodeAsync(batch as Object, getSink());
      });
    },
  );
}
