/// Provides a stream converter for parsing raw RFC 4180 CSV chunks into domain-specific objects.
library;

import 'package:monolib_dart/src/common/chunked_only_converter.dart';
import 'package:monolib_dart/src/csv/csv_base_chunk_sink.dart';

/// A [ChunkedOnlyConverter] that decodes raw RFC 4180 CSV string chunks into individual,
/// domain-specific objects of type [T].
///
/// This decoder acts as a stream transformer. It leverages [CsvBaseChunkSink] to parse
/// incoming string segments into distinct `List<String>` rows. For each row, the user-provided
/// [mapper] function is invoked. If the mapper returns a non-null instance of [T], it is
/// emitted individually down the stream. Returning `null` safely ignores the row.
///
/// Use this class when you need continuous, one-by-one processing of CSV data (e.g., streaming
/// records into a database). For batch-based processing, see [CsvMappedBatchDecoder].
///
/// ```dart
/// final fileStream = File('users.csv').openRead().transform(utf8.decoder);
///
/// final userStream = fileStream.transform(
///   CsvMappedDecoder<User>((row) {
///     if (row.isEmpty || row[0] == 'id') return null; // Skip header or empty lines
///     return User(id: int.parse(row[0]), name: row[1]);
///   }),
/// );
///
/// await for (final user in userStream) {
///   print(user.name);
/// }
/// ```
class CsvMappedDecoder<T> extends ChunkedOnlyConverter<String, T> {
  /// The callback responsible for converting a raw CSV `row` into a domain object [T].
  ///
  /// If this function returns `null`, the row is skipped and not emitted.
  final T? Function(List<String> row) mapper;

  /// An optional callback executed once the source stream completes and all parsed
  /// CSV data has been processed and emitted.
  final void Function()? onDone;

  /// Creates a new [CsvMappedDecoder] with the specified [mapper].
  ///
  /// The optional [onDone] callback can be provided to execute cleanup or finalization
  /// logic when the stream is completely processed.
  const CsvMappedDecoder(this.mapper, {this.onDone});

  /// Initializes the chunked conversion process by creating and returning a
  /// [_CsvMappedDecoderSink] that binds to the provided destination [sink].
  @override
  Sink<String> startChunkedConversion(Sink<T> sink) {
    return _CsvMappedDecoderSink<T>(sink, mapper, onDone: onDone);
  }
}

/// The internal sink implementation that manages stateful chunk processing for [CsvMappedDecoder].
///
/// Inherits string parsing logic from [CsvBaseChunkSink] and applies the [_mapper]
/// to forward individual mapped items of type [T] to the downstream [outSink].
class _CsvMappedDecoderSink<T> extends CsvBaseChunkSink<T> {
  /// The transformation function applied to every parsed row.
  final T? Function(List<String> row) _mapper;

  /// An optional callback invoked upon sink closure.
  final void Function()? onDone;

  /// Instantiates the stateful chunk sink, linking the downstream output, mapping logic,
  /// and completion callback.
  _CsvMappedDecoderSink(super.outSink, this._mapper, {this.onDone});

  /// Invoked by [CsvBaseChunkSink] when a complete CSV row has been successfully parsed.
  ///
  /// Passes the [row] to [_mapper]. If a non-null [T] is returned, it is immediately
  /// added to the downstream output sink.
  @override
  void handleRow(List<String> row) {
    final mapped = _mapper(row);
    if (mapped != null) {
      outSink.add(mapped);
    }
  }

  /// Finalizes the conversion process by flushing any remaining CSV data buffer in
  /// [CsvBaseChunkSink.close] and invoking [onDone], if provided.
  @override
  void close() {
    super.close();
    onDone?.call();
  }
}
