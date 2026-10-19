import 'dart:convert';

import 'package:monolib_dart/src/common/chunked_only_converter.dart';
import 'package:monolib_dart/src/jsonl/jsonl_base_chunk_sink.dart';

/// A streaming converter that parses chunked JSON Lines (JSONL) string data and
/// maps each decoded JSON object into a domain object of type [T].
///
/// [JsonlMappedDecoder] extends [ChunkedOnlyConverter] and uses
/// [JsonlBaseChunkSink] to split incoming string chunks into individual lines.
/// Each line is decoded with [jsonCodec] and passed to [fromJson]; non-null
/// results are emitted individually downstream, while `null` results are
/// skipped.
///
/// For batched emission of mapped items per chunk, see [JsonlMappedBatchDecoder].
///
/// Example:
/// ```dart
/// final fileStream = File('data.jsonl').openRead().transform(utf8.decoder);
///
/// final modelStream = fileStream.transform(
///   JsonlMappedDecoder<MyModel>(
///     (json) => MyModel.fromJson(json as Map<String, dynamic>),
///     ignoreExceptions: true,
///   ),
/// );
///
/// await for (final model in modelStream) {
///   print(model.id);
/// }
/// ```
class JsonlMappedDecoder<T> extends ChunkedOnlyConverter<String, T> {
  final T? Function(dynamic) _fromJson;
  final Codec<Object?, String> _jsonCodec;
  final bool _ignoreExceptions;
  final void Function()? _onDone;

  /// Creates a [JsonlMappedDecoder] that maps decoded JSON lines using [fromJson].
  ///
  /// Optionally configures a custom [jsonCodec], suppresses errors when
  /// [ignoreExceptions] is `true`, and invokes [onDone] when the input stream
  /// completes.
  const JsonlMappedDecoder(
    T? Function(dynamic) fromJson, {
    bool ignoreExceptions = false,
    Codec<Object?, String> jsonCodec = const JsonCodec(),
    void Function()? onDone,
  })  : _fromJson = fromJson,
        _ignoreExceptions = ignoreExceptions,
        _jsonCodec = jsonCodec,
        _onDone = onDone;

  /// Starts a chunked conversion that parses incoming JSONL string chunks, maps
  /// each line using [_fromJson], and emits non-null [T] values to [sink].
  @override
  Sink<String> startChunkedConversion(Sink<T> sink) {
    return _JsonlMappedDecoderSink<T>(
      sink,
      _fromJson,
      _jsonCodec,
      ignoreExceptions: _ignoreExceptions,
      onDone: _onDone,
    );
  }
}

/// Internal [JsonlBaseChunkSink] implementation for [JsonlMappedDecoder].
class _JsonlMappedDecoderSink<T> extends JsonlBaseChunkSink<T> {
  /// The callback applied to every decoded JSON value.
  final T? Function(dynamic) _fromJson;

  /// The codec used to decode individual JSON lines.
  final Codec<Object?, String> _jsonCodec;

  /// Whether to suppress decoding and mapping exceptions.
  final bool _ignoreExceptions;

  /// An optional callback invoked when the sink is closed.
  final void Function()? _onDone;

  /// Creates a sink that decodes JSONL lines with [_jsonCodec], maps them with
  /// [_fromJson], and forwards non-null results to [outSink].
  _JsonlMappedDecoderSink(
    super.outSink,
    this._fromJson,
    Codec<Object?, String> jsonCodec, {
    bool ignoreExceptions = false,
    void Function()? onDone,
  })  : _jsonCodec = jsonCodec,
        _ignoreExceptions = ignoreExceptions,
        _onDone = onDone;

  /// Decodes [line] using [_jsonCodec], maps the result with [_fromJson], and
  /// emits it to [outSink] if non-null.
  ///
  /// Rethrows any exception unless [_ignoreExceptions] is `true`.
  @override
  void processLine(String line) {
    try {
      final json = _jsonCodec.decode(line);
      final mapped = _fromJson(json);
      if (mapped != null) {
        outSink.add(mapped);
      }
    } catch (e) {
      if (!_ignoreExceptions) {
        rethrow;
      }
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
