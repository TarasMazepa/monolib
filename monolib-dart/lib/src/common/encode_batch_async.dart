import 'dart:async';

import 'package:monolib_dart/src/common/async_iterator_util.dart';
import 'package:monolib_dart/src/common/with_lazy_string_sink.dart';

/// Asynchronously encodes a stream of [batches] into a [StringSink] using
/// [encodeAsync].
///
/// This helper backs batch encoders such as `csvEncodeBatchAsync` and
/// `jsonlEncodeBatchAsync`. It uses [withLazyStringSink] so that [sinkProvider]
/// is only invoked when the first batch arrives, and iterates over [batches]
/// sequentially with [iterateStreamOrIterable].
///
/// - [batches]: The stream of item batches to encode sequentially.
/// - [encodeAsync]: Callback invoked for each batch to write formatted data
///   into the target sink.
/// - [sink]: An existing caller-managed [StringSink]. If provided, the caller
///   remains responsible for closing it.
/// - [sinkProvider]: A factory that lazily creates the target [StringSink] when
///   the first batch arrives. If provided, the created sink is automatically
///   closed when encoding completes.
///
/// Exactly one of [sink] or [sinkProvider] must be provided; otherwise, an
/// [ArgumentError] is thrown.
///
/// Example:
/// ```dart
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
