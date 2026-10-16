/// Core engine for asynchronous JSON Lines (JSONL) encoding.
///
/// This library provides [jsonlEncodeAsync], which efficiently serializes
/// streaming collections or iterables into newline-delimited JSON format.
/// It leverages lazy resource allocation and chunked processing to ensure
/// optimal memory usage during high-throughput I/O operations.
library;

import 'dart:async';

import 'package:monolib_dart/src/common/async_iterator_util.dart';
import 'package:monolib_dart/src/common/with_lazy_string_sink.dart';
import 'package:monolib_dart/src/json/json_encode_async.dart';

/// Asynchronously encodes a sequence of [items] into JSON Lines (JSONL) format
/// and writes them sequentially to a destination [StringSink].
///
/// In the repository's architecture, this function acts as the foundational JSONL
/// serialization engine. It processes streaming or iterable collections chunk-by-chunk,
/// preventing out-of-memory errors on massive datasets. It is heavily utilized by
/// higher-level I/O abstractions (such as `JsonlBatchWriter` and `jsonlEncodeBatchAsync`)
/// to decouple asynchronous iteration and individual item serialization from disk
/// writing and batching mechanics.
///
/// It relies on [withLazyStringSink] to manage resource lifecycles. By deferring
/// sink initialization until the first element is processed, it provides zero-byte
/// stream protection (preventing the creation of empty files if [items] is empty).
/// Using a `late final` cache for the sink prevents repetitive evaluation overhead
/// during rapid iteration. Furthermore, it guarantees that a trailing newline is
/// written after each element, even if [jsonEncodeAsync] encounters an error, thereby
/// preserving the structural integrity of the output.
///
/// Either [sink] or [sinkProvider] MUST be provided, but not both.
///
/// - [items]: The sequence of items to serialize. This supports any `Iterable`
///   or asynchronous `Stream`. Each individual item is converted to JSON via
///   [jsonEncodeAsync], which provides universal support for deeply nested `Future`,
///   `Stream`, `Iterable`, standard `toJson()` serialization, and the custom
///   `AsyncJsonWritable` interface.
/// - [sink]: An active, externally managed [StringSink]. If provided, the caller
///   retains ownership and MUST handle closing the resource.
/// - [sinkProvider]: A lazily evaluated factory callback that creates a [StringSink].
///   If provided, this function assumes ownership and will automatically close
///   the sink (awaiting if necessary) when processing completes or an error occurs.
///
/// Example:
/// ```dart
/// // Streaming large amounts of data to an active HTTP response sink.
/// final userStream = database.fetchUsersAsStream();
/// final httpResponse = request.response;
///
/// await jsonlEncodeAsync(
///   items: userStream,
///   sink: httpResponse,
/// );
/// // Note: the caller is responsible for closing `httpResponse` here.
///
/// // Using lazy initialization to only open a file if data actually exists.
/// await jsonlEncodeAsync(
///   items: [{'event': 'startup', 'timestamp': 1690000000}],
///   sinkProvider: () => File('app_logs.jsonl').openWrite(mode: FileMode.append),
/// );
/// ```
Future<void> jsonlEncodeAsync({
  required Object items,
  StringSink? sink,
  StringSink Function()? sinkProvider,
}) {
  return withLazyStringSink(
    sink: sink,
    sinkProvider: sinkProvider,
    action: (getSink) async {
      late final activeSink = getSink();
      await iterateStreamOrIterable(items, (item) async {
        try {
          await jsonEncodeAsync(object: item, sink: activeSink);
        } finally {
          activeSink.writeln();
        }
      });
    },
  );
}
