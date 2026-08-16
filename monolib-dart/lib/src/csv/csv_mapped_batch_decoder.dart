import 'package:monolib_dart/src/common/batching_sink_mixin.dart';
import 'package:monolib_dart/src/common/chunked_only_converter.dart';
import 'package:monolib_dart/src/csv/csv_base_chunk_sink.dart';

class CsvMappedBatchDecoder<T> extends ChunkedOnlyConverter<String, List<T>> {
  final T? Function(List<String> row) mapper;
  final void Function(List<T> batch)? onBatch;

  const CsvMappedBatchDecoder(this.mapper, {this.onBatch});

  @override
  Sink<String> startChunkedConversion(Sink<List<T>> sink) {
    return _CsvMappedBatchDecoderSink<T>(sink, mapper, onBatch: onBatch);
  }
}

class _CsvMappedBatchDecoderSink<T> extends CsvBaseChunkSink<List<T>>
    with BatchingSinkMixin<T> {
  final T? Function(List<String> row) _mapper;
  final void Function(List<T> batch)? onBatch;

  _CsvMappedBatchDecoderSink(super.outSink, this._mapper, {this.onBatch});

  @override
  void handleRow(List<String> row) {
    final mapped = _mapper(row);
    if (mapped != null) {
      addToBatch(mapped);
    }
  }

  @override
  void onChunkEnd() {
    flushBatchOnChunkEnd(onBatch: onBatch);
  }
}
