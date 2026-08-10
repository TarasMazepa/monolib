import 'dart:convert';

import '../common/chunked_only_converter.dart';
import 'jsonl_base_chunk_sink.dart';

/// A Converter that handles chunked string boundaries and parses JSON,
/// dropping nulls along the way. Emits raw dynamic objects.
class JsonlChunkedDecoder extends ChunkedOnlyConverter<String, dynamic> {
  const JsonlChunkedDecoder();

  @override
  Sink<String> startChunkedConversion(Sink<dynamic> sink) {
    return _JsonlChunkedDecoderSink(sink);
  }
}

class _JsonlChunkedDecoderSink extends JsonlBaseChunkSink<dynamic> {
  _JsonlChunkedDecoderSink(super.outSink);

  @override
  void processLine(String line) {
    final json = jsonDecode(line);
    if (json != null) {
      outSink.add(json);
    }
  }
}
