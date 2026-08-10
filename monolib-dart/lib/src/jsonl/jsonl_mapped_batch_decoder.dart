import 'dart:convert';

import 'package:monolib_dart/src/common/batching_sink_mixin.dart';
import 'package:monolib_dart/src/common/chunked_only_converter.dart';
import 'package:monolib_dart/src/jsonl/jsonl_base_chunk_sink.dart';

class JsonlMappedBatchDecoder<T> extends ChunkedOnlyConverter<String, List<T>> {
  final T? Function(dynamic) fromJson;
  final Codec<Object?, String> jsonCodec;
  final bool ignoreExceptions;

  const JsonlMappedBatchDecoder(this.fromJson,
      {this.ignoreExceptions = false, this.jsonCodec = const JsonCodec()});

  @override
  Sink<String> startChunkedConversion(Sink<List<T>> sink) {
    return _JsonlMappedBatchDecoderSink<T>(
      sink,
      fromJson,
      jsonCodec,
      ignoreExceptions: ignoreExceptions,
    );
  }
}

class _JsonlMappedBatchDecoderSink<T> extends JsonlBaseChunkSink<List<T>>
    with BatchingSinkMixin<T> {
  final T? Function(dynamic) _fromJson;
  final Codec<Object?, String> jsonCodec;
  final bool ignoreExceptions;

  _JsonlMappedBatchDecoderSink(super.outSink, this._fromJson, this.jsonCodec,
      {this.ignoreExceptions = false});

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

  @override
  void onChunkEnd() {
    flushBatchOnChunkEnd();
  }
}
