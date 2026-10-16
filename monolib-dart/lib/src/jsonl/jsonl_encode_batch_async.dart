/// High-throughput JSON Lines (JSONL) serialization for batched streams.
///
/// This library provides [jsonlEncodeBatchAsync], which acts as a bridge
/// between asynchronous batch processors (e.g., paginated database queries
/// or chunked stream consumers) and the underlying lazy JSONL encoding engine.
library;

import 'dart:async';

import 'package:monolib_dart/src/common/encode_batch_async.dart';
import 'package:monolib_dart/src/jsonl/jsonl_encode_async.dart';

/// Asynchronously encodes a continuous stream of [batches] into JSON Lines (JSONL).
///
/// In the repository's streaming architecture, this function is used when upstream data
/// is naturally grouped into chunks (e.g., a `Stream<List<Data>>` representing pages
/// of records from a database or CSV parser). It efficiently delegates to [encodeBatchAsync],
/// serializing each item inside the batch using [jsonlEncodeAsync]. This provides universal
/// support for deeply nested `Future`, `Stream`, `Iterable`, standard `toJson()`
/// serialization, and the custom `AsyncJsonWritable` interface.
///
/// This approach prevents flattening the stream in memory, preserving batch-level
/// backpressure while seamlessly writing newline-delimited objects sequentially to
/// the destination.
///
/// Either [sink] or [sinkProvider] MUST be provided, but not both.
///
/// - [batches]: The asynchronous stream of grouped items to serialize.
/// - [sink]: An active, externally managed [StringSink]. If provided, the caller
///   retains ownership and MUST handle closing the resource.
/// - [sinkProvider]: A lazily evaluated factory callback that creates a [StringSink].
///   If provided, this function assumes ownership and will automatically close
///   the sink (awaiting if necessary) when processing completes or an error occurs.
///   It defers sink creation until the first batch arrives, providing zero-byte
///   stream protection.
///
/// Example:
/// ```dart
/// // Fetching users in batches of 100 to prevent out-of-memory errors.
/// final batchedUserStream = database.fetchUsersInBatches(pageSize: 100);
///
/// await jsonlEncodeBatchAsync(
///   batches: batchedUserStream,
///   sinkProvider: () => File('users_export.jsonl').openWrite(mode: FileMode.write),
/// );
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
