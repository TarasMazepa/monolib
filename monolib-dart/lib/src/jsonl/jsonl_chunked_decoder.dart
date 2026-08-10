import 'dart:convert';

import 'package:monolib_dart/src/common/chunked_only_converter.dart';
import 'package:monolib_dart/src/jsonl/jsonl_base_chunk_sink.dart';

/// A Converter that handles chunked string boundaries and parses JSON,
/// dropping nulls along the way. Emits raw dynamic objects.
class JsonlChunkedDecoder extends ChunkedOnlyConverter<String, dynamic> {
  final Codec<Object?, String> jsonCodec;

  const JsonlChunkedDecoder({this.jsonCodec = const JsonCodec()});

  @override
  Sink<String> startChunkedConversion(Sink<dynamic> sink) {
    return _JsonlChunkedDecoderSink(sink, jsonCodec);
  }
}

class _JsonlChunkedDecoderSink extends JsonlBaseChunkSink<dynamic> {
  final Codec<Object?, String> jsonCodec;

  _JsonlChunkedDecoderSink(super.outSink, this.jsonCodec);

  @override
  void processLine(String line) {
    final json = jsonCodec.decode(line);
    if (json != null) {
      outSink.add(json);
    }
  }
}
