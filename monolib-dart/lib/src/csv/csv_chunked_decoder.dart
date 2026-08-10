import 'package:monolib_dart/src/common/chunked_only_converter.dart';
import 'package:monolib_dart/src/csv/csv_base_chunk_sink.dart';

class CsvChunkedDecoder extends ChunkedOnlyConverter<String, List<String>> {
  const CsvChunkedDecoder();

  @override
  Sink<String> startChunkedConversion(Sink<List<String>> sink) {
    return _CsvChunkedDecoderSink(sink);
  }
}

class _CsvChunkedDecoderSink extends CsvBaseChunkSink<List<String>> {
  _CsvChunkedDecoderSink(super.outSink);

  @override
  void handleRow(List<String> row) {
    outSink.add(row);
  }
}
