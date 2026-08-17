import 'package:monolib_dart/src/common/chunked_only_converter.dart';
import 'package:monolib_dart/src/csv/csv_base_chunk_sink.dart';

class CsvMappedDecoder<T> extends ChunkedOnlyConverter<String, T> {
  final T? Function(List<String> row) mapper;
  final void Function()? onDone;

  const CsvMappedDecoder(this.mapper, {this.onDone});

  @override
  Sink<String> startChunkedConversion(Sink<T> sink) {
    return _CsvMappedDecoderSink<T>(sink, mapper, onDone: onDone);
  }
}

class _CsvMappedDecoderSink<T> extends CsvBaseChunkSink<T> {
  final T? Function(List<String> row) _mapper;
  final void Function()? onDone;

  _CsvMappedDecoderSink(super.outSink, this._mapper, {this.onDone});

  @override
  void handleRow(List<String> row) {
    final mapped = _mapper(row);
    if (mapped != null) {
      outSink.add(mapped);
    }
  }

  @override
  void close() {
    super.close();
    onDone?.call();
  }
}
