/// Provides [CsvMappedBatchDecoder], an architectural utility for high-throughput
/// RFC 4180 CSV ingestion that maps parsed rows to domain objects and buffers them into chunks.
library;

import 'package:monolib_dart/src/common/batching_sink_mixin.dart';
import 'package:monolib_dart/src/common/chunked_only_converter.dart';
import 'package:monolib_dart/src/csv/csv_base_chunk_sink.dart';

/// A stream transformer that efficiently ingests raw CSV string chunks, parses them into
/// rows using [CsvBaseChunkSink], maps them to domain objects via a user-provided [mapper],
/// and emits them downstream in batched lists using [BatchingSinkMixin].
///
/// Architecturally, this class extends [ChunkedOnlyConverter] to strictly enforce asynchronous
/// stream processing. By yielding lists of [T] ([List<T>]) rather than individual [T] events
/// (like [CsvMappedDecoder] does), it significantly reduces Dart's asynchronous event loop
/// overhead when processing massive CSV files or high-frequency data streams. Invalid or
/// ignored rows can be safely skipped by returning `null` from the [mapper].
///
/// Example usage within a stream pipeline:
/// ```dart
/// final stream = File('large_data.csv').openRead().transform(utf8.decoder);
/// final decoder = CsvMappedBatchDecoder<User>((row) {
///   if (row.isEmpty || row[0] == 'id') return null; // Skip empty rows or headers
///   return User(id: row[0], name: row[1]);
/// });
///
/// await for (final batch in stream.transform(decoder)) {
///   // Process a batch of User objects
///   await insertUsersToDatabase(batch);
/// }
/// ```
class CsvMappedBatchDecoder<T> extends ChunkedOnlyConverter<String, List<T>> {
  /// The user-provided function that converts a parsed CSV `row` into a domain object [T].
  ///
  /// If this function returns `null`, the row is safely ignored and not added to the current batch.
  final T? Function(List<String> row) mapper;

  /// An optional lifecycle callback invoked with the completed `batch` just before
  /// it is emitted downstream.
  ///
  /// This is useful for side effects like logging, metrics accumulation, or progress
  /// tracking without needing to manually intercept the stream.
  final void Function(List<T> batch)? onBatch;

  /// An optional lifecycle callback invoked when the entire stream processing is complete
  /// and the sink is closed.
  final void Function()? onDone;

  /// Creates a new [CsvMappedBatchDecoder] with the specified [mapper] and optional
  /// lifecycle callbacks [onBatch] and [onDone].
  const CsvMappedBatchDecoder(this.mapper, {this.onBatch, this.onDone});

  @override
  Sink<String> startChunkedConversion(Sink<List<T>> sink) {
    return _CsvMappedBatchDecoderSink<T>(
      sink,
      mapper,
      onBatch: onBatch,
      onDone: onDone,
    );
  }
}

/// The internal chunked conversion sink that powers [CsvMappedBatchDecoder].
///
/// It combines [CsvBaseChunkSink] for RFC 4180 structural string parsing and
/// [BatchingSinkMixin] for efficient memory buffering of domain objects.
class _CsvMappedBatchDecoderSink<T> extends CsvBaseChunkSink<List<T>>
    with BatchingSinkMixin<T> {
  /// The internal reference to the user-provided mapping function.
  final T? Function(List<String> row) _mapper;

  /// The internal reference to the optional batch emission callback.
  final void Function(List<T> batch)? onBatch;

  /// The internal reference to the optional completion callback.
  final void Function()? onDone;

  /// Constructs the sink, piping batched outputs to [outSink] and configuring
  /// the [_mapper] and lifecycle callbacks [onBatch] and [onDone].
  _CsvMappedBatchDecoderSink(
    super.outSink,
    this._mapper, {
    this.onBatch,
    this.onDone,
  });

  /// Processes a fully parsed CSV [row] from the incoming string chunk.
  ///
  /// It evaluates the [row] using the user-provided [_mapper]. If the mapping
  /// produces a valid object, it buffers it using [addToBatch].
  @override
  void handleRow(List<String> row) {
    final mapped = _mapper(row);
    if (mapped != null) {
      addToBatch(mapped);
    }
  }

  /// Triggered at the end of every incoming string chunk lifecycle.
  ///
  /// It flushes any internally accumulated domain objects downstream as a single list,
  /// executing the [onBatch] callback if provided.
  @override
  void onChunkEnd() {
    flushBatchOnChunkEnd(onBatch: onBatch);
  }

  /// Closes the chunk sink, flushing any trailing parsing state and invoking
  /// the [onDone] lifecycle callback.
  @override
  void close() {
    super.close();
    onDone?.call();
  }
}
