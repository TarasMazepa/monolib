import 'dart:convert';

import '../common/chunked_only_converter.dart';
import 'jsonl_base_chunk_sink.dart';

/// A Converter that fuses line-splitting directly into JSON mapping,
/// avoiding the stream event overhead of LineSplitterConverter.
class JsonlMappedDecoder<T> extends ChunkedOnlyConverter<String, T> {
  final T? Function(dynamic) fromJson;
  final bool ignoreExceptions;

  const JsonlMappedDecoder(this.fromJson, {this.ignoreExceptions = false});

  @override
  Sink<String> startChunkedConversion(Sink<T> sink) {
    return _JsonlMappedDecoderSink<T>(
      sink,
      fromJson,
      ignoreExceptions: ignoreExceptions,
    );
  }
}

class _JsonlMappedDecoderSink<T> extends JsonlBaseChunkSink<T> {
  final T? Function(dynamic) _fromJson;
  final bool ignoreExceptions;

  _JsonlMappedDecoderSink(super.outSink, this._fromJson,
      {this.ignoreExceptions = false});

  @override
  void processLine(String line) {
    try {
      final json = jsonDecode(line);
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
}
