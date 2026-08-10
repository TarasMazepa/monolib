import 'dart:convert';

import '../common/chunked_only_converter.dart';
import 'jsonl_base_chunk_sink.dart';

class JsonlMappedBatchDecoder<T> extends ChunkedOnlyConverter<String, List<T>> {
  final T? Function(dynamic) fromJson;
  final bool ignoreExceptions;

  const JsonlMappedBatchDecoder(this.fromJson, {this.ignoreExceptions = false});

  @override
  Sink<String> startChunkedConversion(Sink<List<T>> sink) {
    return _JsonlMappedBatchDecoderSink<T>(
      sink,
      fromJson,
      ignoreExceptions: ignoreExceptions,
    );
  }
}

class _JsonlMappedBatchDecoderSink<T> extends JsonlBaseChunkSink<List<T>> {
  final T? Function(dynamic) _fromJson;
  final bool ignoreExceptions;
  List<T> _batch = [];

  _JsonlMappedBatchDecoderSink(super.outSink, this._fromJson,
      {this.ignoreExceptions = false});

  @override
  void processLine(String line) {
    try {
      final json = jsonDecode(line);
      final mapped = _fromJson(json);
      if (mapped != null) {
        _batch.add(mapped);
      }
    } catch (e) {
      if (!ignoreExceptions) {
        rethrow;
      }
    }
  }

  @override
  void onChunkEnd() {
    if (_batch.isNotEmpty) {
      outSink.add(_batch);
      _batch = [];
    }
  }
}
