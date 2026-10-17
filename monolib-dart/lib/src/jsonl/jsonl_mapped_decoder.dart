/// Provides [JsonlMappedDecoder], a stream transformer for decoding JSON Lines.
library;

import 'dart:convert';

import 'package:monolib_dart/src/common/chunked_only_converter.dart';
import 'package:monolib_dart/src/jsonl/jsonl_base_chunk_sink.dart';

/// A [Converter] that efficiently parses chunked JSON Lines (JSONL) string data
/// and maps each decoded JSON object into a strongly-typed instance of [T].
///
/// This decoder acts as a stream transformer specifically designed to fuse
/// line-splitting directly into JSON string decoding and object mapping. By
/// bypassing the intermediate stream events typical of Dart's `LineSplitter`, it
/// reduces overhead and memory allocations when reading high-throughput data
/// streams, such as from files or network responses.
///
/// It extends [ChunkedOnlyConverter], emphasizing its architectural role as a
/// stream-processing utility. Invoking the synchronous `convert` method directly
/// will throw an [UnsupportedError].
///
/// The user-provided [fromJson] callback is invoked on every successfully parsed
/// JSON object. If [fromJson] returns `null`, the row is safely ignored,
/// allowing for inline filtering.
///
/// Example:
/// ```dart
/// final stream = File('data.jsonl').openRead().transform(utf8.decoder);
///
/// final objects = stream.transform(
///   JsonlMappedDecoder<MyModel>(
///     (json) => MyModel.fromJson(json as Map<String, dynamic>),
///     ignoreExceptions: true,
///   ),
/// );
///
/// await for (final model in objects) {
///   print(model.id);
/// }
/// ```
class JsonlMappedDecoder<T> extends ChunkedOnlyConverter<String, T> {
  /// The mapping callback invoked to convert a parsed JSON object into [T].
  ///
  /// If this callback returns `null`, the value is skipped and not emitted
  /// into the output stream.
  final T? Function(dynamic) fromJson;

  /// The underlying [Codec] used to parse the extracted line strings into JSON.
  ///
  /// Defaults to standard [JsonCodec].
  final Codec<Object?, String> jsonCodec;

  /// Whether to suppress exceptions during JSON decoding or mapping.
  ///
  /// If `true`, lines that fail to decode or throw during [fromJson] evaluation
  /// are silently skipped. If `false` (default), the error propagates to the
  /// stream's error channel.
  final bool ignoreExceptions;

  /// An optional callback triggered exactly once when the source stream closes.
  final void Function()? onDone;

  /// Creates a [JsonlMappedDecoder] that converts JSONL string chunks into [T].
  ///
  /// The [fromJson] callback is required to map the dynamic JSON object.
  /// Optionally, you can provide a custom [jsonCodec], swallow errors with
  /// [ignoreExceptions], or perform cleanup using [onDone].
  const JsonlMappedDecoder(
    this.fromJson, {
    this.ignoreExceptions = false,
    this.jsonCodec = const JsonCodec(),
    this.onDone,
  });

  /// Initiates a chunked conversion by returning a specialized sink.
  ///
  /// This bridges the incoming raw `String` chunks to the outgoing [sink] for [T].
  @override
  Sink<String> startChunkedConversion(Sink<T> sink) {
    return _JsonlMappedDecoderSink<T>(
      sink,
      fromJson,
      jsonCodec,
      ignoreExceptions: ignoreExceptions,
      onDone: onDone,
    );
  }
}

/// The internal [ChunkedConversionSink] utilized by [JsonlMappedDecoder] to
/// buffer strings and map JSON objects.
///
/// This delegates the raw string splitting to [JsonlBaseChunkSink], which
/// handles carrying over incomplete segments across asynchronous stream chunks.
/// When a full line is yielded via [processLine], it parses it using [jsonCodec]
/// and maps it via [_fromJson].
class _JsonlMappedDecoderSink<T> extends JsonlBaseChunkSink<T> {
  /// The callback responsible for mapping parsed JSON to [T].
  final T? Function(dynamic) _fromJson;

  /// The codec used for JSON decoding of the string line.
  final Codec<Object?, String> jsonCodec;

  /// If true, swallows format or mapping exceptions.
  final bool ignoreExceptions;

  /// Executed when the stream is completely closed.
  final void Function()? onDone;

  /// Constructs the sink, chaining the mapped output to [outSink].
  _JsonlMappedDecoderSink(
    super.outSink,
    this._fromJson,
    this.jsonCodec, {
    this.ignoreExceptions = false,
    this.onDone,
  });

  /// Processes a single, complete line of JSON text.
  ///
  /// Attempts to decode the string using [jsonCodec], pass it through
  /// [_fromJson], and forward non-null values to the target `outSink`.
  /// Honors the [ignoreExceptions] flag if decoding or mapping fails.
  @override
  void processLine(String line) {
    try {
      final json = jsonCodec.decode(line);
      final mapped = _fromJson(json);
      if (mapped != null) {
        outSink.add(mapped);
      }
    } catch (e) {
      if (!ignoreExceptions) {
        rethrow;
      }
    }
  }

  /// Flushes any remaining incomplete lines and signals completion.
  ///
  /// Invokes [onDone] before finally closing the underlying `outSink`.
  @override
  void close() {
    super.close();
    onDone?.call();
  }
}
