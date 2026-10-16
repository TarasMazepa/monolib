/// Provides high-throughput, memory-efficient decoding of JSON Lines (JSONL) data
/// into batched collections of strongly-typed domain objects.
library;

import 'dart:convert';

import 'package:monolib_dart/src/common/batching_sink_mixin.dart';
import 'package:monolib_dart/src/common/chunked_only_converter.dart';
import 'package:monolib_dart/src/jsonl/jsonl_base_chunk_sink.dart';

/// A specialized converter designed to aggressively optimize stream processing of JSONL data.
///
/// Within the repository's data-parsing architecture, [JsonlMappedBatchDecoder] avoids
/// emitting one event per line. Instead, it aggregates multiple parsed JSON objects into a
/// single [List] event per underlying data chunk, reducing event loop scheduling overhead and
/// increasing overall stream throughput.
///
/// It extends [ChunkedOnlyConverter] as it relies on [JsonlBaseChunkSink] and [BatchingSinkMixin]
/// to handle stateful line parsing and batch accumulation across stream boundaries. It is not intended
/// for synchronous single-value conversions.
///
/// Example:
/// ```dart
/// final stream = Stream.fromIterable([
///   '{"id": 1}\n{"id": 2}',
///   '\n{"id": 3}'
/// ]);
///
/// final batchedStream = stream.transform(
///   JsonlMappedBatchDecoder((json) => MyDomainObject.fromJson(json)),
/// );
///
/// // Emits:
/// // [MyDomainObject(1), MyDomainObject(2)]
/// // [MyDomainObject(3)]
/// ```
class JsonlMappedBatchDecoder<T> extends ChunkedOnlyConverter<String, List<T>> {
  /// The factory function used to transform parsed dynamic JSON objects into the domain type [T].
  ///
  /// If this function returns `null`, the specific item is filtered out and will not be included
  /// in the emitted batch, enabling on-the-fly data validation and sanitization.
  final T? Function(dynamic) fromJson;

  /// The underlying codec utilized to parse individual JSON string lines.
  ///
  /// Defaults to standard [JsonCodec] but allows injecting custom or optimized JSON decoders.
  final Codec<Object?, String> jsonCodec;

  /// Dictates the error handling policy during JSON decoding and object mapping.
  ///
  /// When `true`, any exceptions thrown by [jsonCodec] or [fromJson] are swallowed, discarding
  /// the malformed line and allowing processing to continue. When `false` (the default), such
  /// errors are immediately rethrown, terminating the stream transformation.
  final bool ignoreExceptions;

  /// An optional lifecycle hook invoked synchronously with the accumulated batch just before it is
  /// forwarded to the underlying stream sink.
  ///
  /// This enables side-effects (e.g., logging or metrics gathering) directly on the grouped data.
  final void Function(List<T> batch)? onBatch;

  /// An optional callback executed once the final chunk has been processed and the stream is fully closed.
  final void Function()? onDone;

  /// Instantiates a new [JsonlMappedBatchDecoder] to process incoming JSONL strings into batches
  /// of [T].
  const JsonlMappedBatchDecoder(
    this.fromJson, {
    this.ignoreExceptions = false,
    this.jsonCodec = const JsonCodec(),
    this.onBatch,
    this.onDone,
  });

  /// Initiates the stateful chunked conversion pipeline.
  ///
  /// Returns a specialized [_JsonlMappedBatchDecoderSink] that manages partial line state,
  /// maps JSON payloads, and batches them before delegating to the target [sink].
  @override
  Sink<String> startChunkedConversion(Sink<List<T>> sink) {
    return _JsonlMappedBatchDecoderSink<T>(
      sink,
      fromJson,
      jsonCodec,
      ignoreExceptions: ignoreExceptions,
      onBatch: onBatch,
      onDone: onDone,
    );
  }
}

/// The internal stateful sink driving the logic for [JsonlMappedBatchDecoder].
///
/// It combines [JsonlBaseChunkSink] to correctly identify individual JSON lines across arbitrary
/// string chunk boundaries, and [BatchingSinkMixin] to buffer the successfully mapped instances of [T]
/// until the end of the current chunk is reached.
class _JsonlMappedBatchDecoderSink<T> extends JsonlBaseChunkSink<List<T>>
    with BatchingSinkMixin<T> {
  /// Maps raw JSON to the generic type [T], silently dropping `null` returns.
  final T? Function(dynamic) _fromJson;

  /// The codec used to parse complete JSON string lines.
  final Codec<Object?, String> jsonCodec;

  /// Whether to suppress mapping and parsing exceptions.
  final bool ignoreExceptions;

  /// Callback fired when a populated batch is flushed.
  final void Function(List<T> batch)? onBatch;

  /// Callback fired when the sink completes its lifecycle.
  final void Function()? onDone;

  /// Constructs the stateful mapping and batching sink, routing final batches into [outSink].
  _JsonlMappedBatchDecoderSink(
    super.outSink,
    this._fromJson,
    this.jsonCodec, {
    this.ignoreExceptions = false,
    this.onBatch,
    this.onDone,
  });

  /// Decodes and maps a single, complete line of JSONL data.
  ///
  /// Successful conversions are buffered using [BatchingSinkMixin.addToBatch]. Malformed data or
  /// exceptions within [_fromJson] will either be swallowed (if [ignoreExceptions] is `true`) or
  /// propagated upwards.
  @override
  void processLine(String line) {
    try {
      final json = jsonCodec.decode(line);
      final mapped = _fromJson(json);
      if (mapped != null) {
        addToBatch(mapped);
      }
    } catch (e) {
      if (!ignoreExceptions) {
        rethrow;
      }
    }
  }

  /// Triggered natively by [JsonlBaseChunkSink] when an incoming string chunk has been fully processed.
  ///
  /// Flushes any accumulated items using [BatchingSinkMixin.flushBatchOnChunkEnd], dispatching
  /// the single batched event downstream.
  @override
  void onChunkEnd() {
    flushBatchOnChunkEnd(onBatch: onBatch);
  }

  /// Finalizes the sink, flushing remaining data and triggering [onDone] if provided.
  @override
  void close() {
    super.close();
    onDone?.call();
  }
}
