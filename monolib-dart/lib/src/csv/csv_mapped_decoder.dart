import 'package:monolib_dart/src/common/chunked_only_converter.dart';
import 'package:monolib_dart/src/csv/csv_base_chunk_sink.dart';

/// A streaming converter that parses chunked RFC 4180 CSV string data and maps
/// each parsed row into a domain object of type [T].
///
/// [CsvMappedDecoder] extends [ChunkedOnlyConverter] and uses [CsvBaseChunkSink]
/// to split incoming string chunks into `List<String>` rows. Each row is passed
/// to [mapper]; non-null results are emitted individually downstream, while
/// `null` results are skipped.
///
/// For batched emission of mapped items per chunk, see [CsvMappedBatchDecoder].
///
/// Example:
/// ```dart
/// final fileStream = File('users.csv').openRead().transform(utf8.decoder);
///
/// final userStream = fileStream.transform(
///   CsvMappedDecoder<User>((row) {
///     if (row.isEmpty || row[0] == 'id') return null;
///     return User(id: int.parse(row[0]), name: row[1]);
///   }),
/// );
///
/// await for (final user in userStream) {
///   print(user.name);
/// }
/// ```
class CsvMappedDecoder<T> extends ChunkedOnlyConverter<String, T> {
  /// The callback invoked to convert a parsed CSV `row` into an instance of [T].
  ///
  /// Returning `null` skips the row without emitting an event.
  final T? Function(List<String> row) mapper;

  /// An optional callback invoked once when the input stream closes.
  final void Function()? onDone;

  /// Creates a [CsvMappedDecoder] that maps parsed CSV rows using [mapper].
  ///
  /// Optionally invokes [onDone] when the input stream completes.
  const CsvMappedDecoder(this.mapper, {this.onDone});

  /// Starts a chunked conversion that parses incoming CSV string chunks, maps
  /// each row using [mapper], and emits non-null [T] values to [sink].
  @override
  Sink<String> startChunkedConversion(Sink<T> sink) {
    return _CsvMappedDecoderSink<T>(sink, mapper, onDone: onDone);
  }
}

/// Internal [CsvBaseChunkSink] implementation for [CsvMappedDecoder].
class _CsvMappedDecoderSink<T> extends CsvBaseChunkSink<T> {
  /// The callback applied to every parsed CSV `row`.
  final T? Function(List<String> row) _mapper;

  /// An optional callback invoked when the sink is closed.
  final void Function()? _onDone;

  /// Creates a sink that maps parsed CSV rows with [_mapper] and forwards
  /// non-null results to [outSink].
  _CsvMappedDecoderSink(super.outSink, this._mapper, {void Function()? onDone})
      : _onDone = onDone;

  /// Maps [row] using [_mapper] and emits the result to [outSink] if non-null.
  @override
  void handleRow(List<String> row) {
    final mapped = _mapper(row);
    if (mapped != null) {
      outSink.add(mapped);
    }
  }

  /// Flushes any remaining buffered data, closes [outSink], and invokes
  /// [_onDone] if provided.
  @override
  void close() {
    super.close();
    _onDone?.call();
  }
}
