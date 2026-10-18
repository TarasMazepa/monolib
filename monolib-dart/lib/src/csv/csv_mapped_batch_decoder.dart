import 'package:monolib_dart/src/common/batching_sink_mixin.dart';
import 'package:monolib_dart/src/common/chunked_only_converter.dart';
import 'package:monolib_dart/src/csv/csv_base_chunk_sink.dart';

/// A streaming converter that parses chunked RFC 4180 CSV string data, maps
/// each parsed row into a domain object of type [T], and emits mapped items in
/// per-chunk batches (`List<T>`).
///
/// [CsvMappedBatchDecoder] extends [ChunkedOnlyConverter] and combines
/// [CsvBaseChunkSink] with [BatchingSinkMixin]. Each parsed row is passed to
/// [mapper]; non-null results are accumulated and flushed as a single
/// `List<T>` batch at the end of each input chunk, reducing stream event
/// overhead on high-volume CSV streams.
///
/// For one-by-one emission of mapped items, see [CsvMappedDecoder].
///
/// Example:
/// ```dart
/// final fileStream = File('large_data.csv').openRead().transform(utf8.decoder);
///
/// final batchStream = fileStream.transform(
///   CsvMappedBatchDecoder<User>((row) {
///     if (row.isEmpty || row[0] == 'id') return null;
///     return User(id: int.parse(row[0]), name: row[1]);
///   }),
/// );
///
/// await for (final batch in batchStream) {
///   await insertUsersToDatabase(batch);
/// }
/// ```
class CsvMappedBatchDecoder<T> extends ChunkedOnlyConverter<String, List<T>> {
  /// The callback invoked to convert a parsed CSV `row` into an instance of [T].
  ///
  /// Returning `null` skips the row and excludes it from the current batch.
  final T? Function(List<String> row) mapper;

  /// An optional callback invoked with each non-empty `batch` just before it is
  /// emitted downstream.
  final void Function(List<T> batch)? onBatch;

  /// An optional callback invoked once when the input stream closes.
  final void Function()? onDone;

  /// Creates a [CsvMappedBatchDecoder] that maps parsed CSV rows using [mapper]
  /// and emits them in batches.
  ///
  /// Optionally invokes [onBatch] before each batch is emitted and [onDone]
  /// when the input stream completes.
  const CsvMappedBatchDecoder(this.mapper, {this.onBatch, this.onDone});

  /// Starts a chunked conversion that parses incoming CSV string chunks, maps
  /// each row using [mapper], and emits non-empty `List<T>` batches to [sink].
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

/// Internal [CsvBaseChunkSink] implementation for [CsvMappedBatchDecoder].
class _CsvMappedBatchDecoderSink<T> extends CsvBaseChunkSink<List<T>>
    with BatchingSinkMixin<T> {
  /// The callback applied to every parsed CSV `row`.
  final T? Function(List<String> row) _mapper;

  /// An optional callback invoked when a non-empty `batch` is flushed.
  final void Function(List<T> batch)? onBatch;

  /// An optional callback invoked when the sink is closed.
  final void Function()? onDone;

  /// Creates a sink that maps parsed CSV rows with [_mapper], batches non-null
  /// results, and forwards each batch to [outSink].
  _CsvMappedBatchDecoderSink(
    super.outSink,
    this._mapper, {
    this.onBatch,
    this.onDone,
  });

  /// Maps [row] using [_mapper] and adds the result to the current batch via
  /// [addToBatch] if non-null.
  @override
  void handleRow(List<String> row) {
    final mapped = _mapper(row);
    if (mapped != null) {
      addToBatch(mapped);
    }
  }

  /// Flushes any accumulated items in the current batch to [outSink] via
  /// [flushBatchOnChunkEnd], invoking [onBatch] if provided.
  @override
  void onChunkEnd() {
    flushBatchOnChunkEnd(onBatch: onBatch);
  }

  /// Flushes any remaining buffered data, closes [outSink], and invokes
  /// [onDone] if provided.
  @override
  void close() {
    super.close();
    onDone?.call();
  }
}
