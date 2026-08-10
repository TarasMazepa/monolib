import 'dart:convert';

import 'package:monolib_dart/src/common/list_accumulator_sink.dart';
import 'package:monolib_dart/src/jsonl/jsonl_chunked_decoder.dart';

class JsonlDecoder extends Converter<String, List<dynamic>> {
  final Codec<Object?, String> jsonCodec;

  const JsonlDecoder(this.jsonCodec);

  @override
  List<dynamic> convert(String items) {
    final sink = ListAccumulatorSink<dynamic>();
    JsonlChunkedDecoder(jsonCodec: jsonCodec).startChunkedConversion(sink)
      ..add(items)
      ..close();
    return sink.results;
  }
}
