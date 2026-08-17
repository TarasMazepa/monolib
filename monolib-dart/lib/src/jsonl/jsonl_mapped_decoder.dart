import 'dart:convert';

import 'package:monolib_dart/src/common/chunked_only_converter.dart';
import 'package:monolib_dart/src/jsonl/jsonl_base_chunk_sink.dart';

/// A Converter that fuses line-splitting directly into JSON mapping,
/// avoiding the stream event overhead of LineSplitterConverter.
class JsonlMappedDecoder<T> extends ChunkedOnlyConverter<String, T> {
  final T? Function(dynamic) fromJson;
  final Codec<Object?, String> jsonCodec;
  final bool ignoreExceptions;
  final void Function()? onDone;

  const JsonlMappedDecoder(
    this.fromJson, {
    this.ignoreExceptions = false,
    this.jsonCodec = const JsonCodec(),
    this.onDone,
  });

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

class _JsonlMappedDecoderSink<T> extends JsonlBaseChunkSink<T> {
  final T? Function(dynamic) _fromJson;
  final Codec<Object?, String> jsonCodec;
  final bool ignoreExceptions;
  final void Function()? onDone;

  _JsonlMappedDecoderSink(
    super.outSink,
    this._fromJson,
    this.jsonCodec, {
    this.ignoreExceptions = false,
    this.onDone,
  });

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

  @override
  void close() {
    super.close();
    onDone?.call();
  }
}
