import 'dart:convert';

import 'package:monolib_dart/src/common/list_accumulator_sink.dart';

import 'package:monolib_dart/src/csv/csv_chunked_decoder.dart';

class CsvDecoder extends Converter<String, List<List<String>>> {
  const CsvDecoder();

  @override
  List<List<String>> convert(String items) {
    final sink = ListAccumulatorSink<List<String>>();
    const CsvChunkedDecoder().startChunkedConversion(sink)
      ..add(items)
      ..close();
    return sink.results;
  }
}
