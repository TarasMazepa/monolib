import 'package:monolib_dart/src/common/batching_sink_mixin.dart';
import 'package:monolib_dart/src/common/chunked_only_converter.dart';
import 'package:monolib_dart/src/csv/csv_base_chunk_sink.dart';

class CsvMappedBatchDecoder<T> extends ChunkedOnlyConverter<String, List<T>> {
  final T? Function(List<String> row) mapper;

  const CsvMappedBatchDecoder(this.mapper);

  @override
  Sink<String> startChunkedConversion(Sink<List<T>> sink) {
    return _CsvMappedBatchDecoderSink<T>(sink, mapper);
  }
}

class _CsvMappedBatchDecoderSink<T> extends CsvBaseChunkSink<List<T>>
    with BatchingSinkMixin<T> {
  final T? Function(List<String> row) _mapper;

  _CsvMappedBatchDecoderSink(super.outSink, this._mapper);

  @override
  void handleRow(List<String> row) {
    final mapped = _mapper(row);
    if (mapped != null) {
      addToBatch(mapped);
    }
  }

  @override
  void onChunkEnd() {
    flushBatchOnChunkEnd();
  }
}
