import 'dart:async';

import 'package:monolib_dart/src/common/encode_batch_async.dart';
import 'package:monolib_dart/src/jsonl/jsonl_encode_async.dart';

/// Asynchronously encodes a stream of [batches] into JSON Lines (JSONL) format
/// and writes each line to a destination [StringSink].
///
/// Delegates batch traversal and lazy sink management to [encodeBatchAsync],
/// encoding each non-empty batch with [jsonlEncodeAsync]. Exactly one of [sink]
/// or [sinkProvider] must be provided, or an [ArgumentError] is thrown.
///
/// - [batches]: The [Stream] of item batches (`List<T>`) to encode. Each item
///   of type [T] is serialized via `jsonEncodeAsync`, which supports nested
///   [Future], [Stream], and [Iterable] values, `toJson()` methods, and
///   `AsyncJsonWritable` objects.
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
///   [{'name': 'Alice', 'age': 30}],
///   [{'name': 'Bob', 'age': 25}],
/// ]);
/// final buffer = StringBuffer();
///
/// await jsonlEncodeBatchAsync(
///   batches: batchesStream,
///   sink: buffer,
/// );
/// print(buffer.toString());
/// // Result: '{"name":"Alice","age":30}\n{"name":"Bob","age":25}\n'
/// ```
Future<void> jsonlEncodeBatchAsync<T>({
  required Stream<List<T>> batches,
  StringSink? sink,
  StringSink Function()? sinkProvider,
}) {
  return encodeBatchAsync(
    batches: batches,
    encodeAsync: (items, sink) => jsonlEncodeAsync(items: items, sink: sink),
    sink: sink,
    sinkProvider: sinkProvider,
  );
}
