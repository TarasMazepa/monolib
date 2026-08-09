import '../common/chunked_only_converter.dart';
import 'csv_base_chunk_sink.dart';

class CsvMappedBatchDecoder<T> extends ChunkedOnlyConverter<String, List<T>> {
  final T? Function(List<String> row) mapper;

  const CsvMappedBatchDecoder(this.mapper);

  @override
  Sink<String> startChunkedConversion(Sink<List<T>> sink) {
    return _CsvMappedBatchDecoderSink<T>(sink, mapper);
  }
}

class _CsvMappedBatchDecoderSink<T> extends CsvBaseChunkSink<List<T>> {
  final T? Function(List<String> row) _mapper;
  List<T> _batch = [];

  _CsvMappedBatchDecoderSink(super.outSink, this._mapper);

  @override
  void handleRow(List<String> row) {
    final mapped = _mapper(row);
    if (mapped != null) {
      _batch.add(mapped);
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
