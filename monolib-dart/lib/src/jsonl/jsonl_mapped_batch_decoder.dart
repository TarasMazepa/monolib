import 'dart:convert';

import 'package:monolib_dart/src/common/batching_sink_mixin.dart';
import 'package:monolib_dart/src/common/chunked_only_converter.dart';
import 'package:monolib_dart/src/jsonl/jsonl_base_chunk_sink.dart';

/// A streaming converter that parses chunked JSON Lines (JSONL) string data,
/// maps each decoded JSON object into a domain object of type [T], and emits
/// mapped items in per-chunk batches (`List<T>`).
///
/// [JsonlMappedBatchDecoder] extends [ChunkedOnlyConverter] and combines
/// [JsonlBaseChunkSink] with [BatchingSinkMixin]. Each parsed line is decoded
/// with [jsonCodec] and passed to [fromJson]; non-null results are accumulated
/// and flushed as a single `List<T>` batch at the end of each input chunk,
/// reducing stream event overhead on high-volume JSONL streams.
///
/// For one-by-one emission of mapped items, see [JsonlMappedDecoder].
///
/// Example:
/// ```dart
/// final fileStream = File('large_data.jsonl').openRead().transform(utf8.decoder);
///
/// final batchStream = fileStream.transform(
///   JsonlMappedBatchDecoder<MyModel>(
///     (json) => MyModel.fromJson(json as Map<String, dynamic>),
///     ignoreExceptions: true,
///   ),
/// );
///
/// await for (final batch in batchStream) {
///   await insertModelsToDatabase(batch);
/// }
/// ```
class JsonlMappedBatchDecoder<T> extends ChunkedOnlyConverter<String, List<T>> {
  final T? Function(dynamic) _fromJson;
  final Codec<Object?, String> _jsonCodec;
  final bool _ignoreExceptions;
  final void Function(List<T> batch)? _onBatch;
  final void Function()? _onDone;

  /// Creates a [JsonlMappedBatchDecoder] that maps decoded JSON lines using
  /// [fromJson] and emits them in batches.
  ///
  /// Optionally configures a custom [jsonCodec], suppresses errors when
  /// [ignoreExceptions] is `true`, invokes [onBatch] before each batch is
  /// emitted, and invokes [onDone] when the input stream completes.
  const JsonlMappedBatchDecoder(
    T? Function(dynamic) fromJson, {
    bool ignoreExceptions = false,
    Codec<Object?, String> jsonCodec = const JsonCodec(),
    void Function(List<T> batch)? onBatch,
    void Function()? onDone,
  })  : _fromJson = fromJson,
        _ignoreExceptions = ignoreExceptions,
        _jsonCodec = jsonCodec,
        _onBatch = onBatch,
        _onDone = onDone;

  /// Starts a chunked conversion that parses incoming JSONL string chunks, maps
  /// each line using [_fromJson], and emits non-empty `List<T>` batches to [sink].
  @override
  Sink<String> startChunkedConversion(Sink<List<T>> sink) {
    return _JsonlMappedBatchDecoderSink<T>(
      sink,
      _fromJson,
      _jsonCodec,
      ignoreExceptions: _ignoreExceptions,
      onBatch: _onBatch,
      onDone: _onDone,
    );
  }
}

/// Internal [JsonlBaseChunkSink] implementation for [JsonlMappedBatchDecoder].
class _JsonlMappedBatchDecoderSink<T> extends JsonlBaseChunkSink<List<T>>
    with BatchingSinkMixin<T> {
  /// The callback applied to every decoded JSON value.
  final T? Function(dynamic) _fromJson;

  /// The codec used to decode individual JSON lines.
  final Codec<Object?, String> _jsonCodec;

  /// Whether to suppress decoding and mapping exceptions.
  final bool _ignoreExceptions;

  /// An optional callback invoked when a non-empty `batch` is flushed.
  final void Function(List<T> batch)? _onBatch;

  /// An optional callback invoked when the sink is closed.
  final void Function()? _onDone;

  /// Creates a sink that decodes JSONL lines with [_jsonCodec], maps them with
  /// [_fromJson], batches non-null results, and forwards each batch to [outSink].
  _JsonlMappedBatchDecoderSink(
    super.outSink,
    this._fromJson,
    Codec<Object?, String> jsonCodec, {
    bool ignoreExceptions = false,
    void Function(List<T> batch)? onBatch,
    void Function()? onDone,
  })  : _jsonCodec = jsonCodec,
        _ignoreExceptions = ignoreExceptions,
        _onBatch = onBatch,
        _onDone = onDone;

  /// Decodes [line] using [_jsonCodec], maps the result with [_fromJson], and
  /// adds it to the current batch via [addToBatch] if non-null.
  ///
  /// Rethrows any exception unless [_ignoreExceptions] is `true`.
  @override
  void processLine(String line) {
    try {
      final json = _jsonCodec.decode(line);
      final mapped = _fromJson(json);
      if (mapped != null) {
        addToBatch(mapped);
      }
    } catch (e) {
      if (!_ignoreExceptions) {
        rethrow;
      }
    }
  }

  /// Flushes any accumulated items in the current batch to [outSink] via
  /// [flushBatchOnChunkEnd], invoking [_onBatch] if provided.
  @override
  void onChunkEnd() {
    flushBatchOnChunkEnd(onBatch: _onBatch);
  }

  /// Flushes any remaining buffered data, closes [outSink], and invokes
  /// [_onDone] if provided.
  @override
  void close() {
    super.close();
    _onDone?.call();
  }
}
