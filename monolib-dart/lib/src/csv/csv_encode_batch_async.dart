import 'dart:async';

import 'package:monolib_dart/src/common/encode_batch_async.dart';
import 'package:monolib_dart/src/csv/csv_encode_async.dart';

/// Asynchronously encodes a stream of [batches] into RFC 4180 CSV format and
/// writes each row to a destination [StringSink].
///
/// Delegates batch traversal and lazy sink management to [encodeBatchAsync],
/// encoding each non-empty batch with [csvEncodeAsync]. Exactly one of [sink]
/// or [sinkProvider] must be provided, or an [ArgumentError] is thrown.
///
/// - [batches]: The [Stream] of item batches (`List<T>`) to encode. Each item
///   of type [T] must be a [List] representing a row, an object implementing
///   `toCsv()` that returns a [List], or a [Future] resolving to one of those.
/// - [sink]: An active, externally managed [StringSink]. If provided, the
///   caller retains ownership and is responsible for closing it.
/// - [sinkProvider]: A factory callback that lazily creates a [StringSink] when
///   the first non-empty batch arrives (preventing empty files when [batches]
///   yields no items). The created sink is closed automatically upon completion
///   or error if it implements [Sink] or [StreamSink].
///
/// Example:
/// ```dart
/// final batchesStream = Stream.fromIterable([
///   [['Name', 'Age'], ['Alice', 30]],
///   [['Bob', 25]],
/// ]);
/// final buffer = StringBuffer();
///
/// await csvEncodeBatchAsync(
///   batches: batchesStream,
///   sink: buffer,
/// );
/// print(buffer.toString());
/// // Result: 'Name,Age\r\nAlice,30\r\nBob,25\r\n'
/// ```
Future<void> csvEncodeBatchAsync<T>({
  required Stream<List<T>> batches,
  StringSink? sink,
  StringSink Function()? sinkProvider,
}) {
  return encodeBatchAsync(
    batches: batches,
    encodeAsync: (items, sink) => csvEncodeAsync(items: items, sink: sink),
    sink: sink,
    sinkProvider: sinkProvider,
  );
}
