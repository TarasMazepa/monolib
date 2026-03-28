import 'dart:convert';

import 'jsonl_decoder.dart';
import 'jsonl_encoder.dart';

class JsonlCodec extends Codec<List<dynamic>, String> {
  final Codec<Object?, String> jsonCodec;

  const JsonlCodec({this.jsonCodec = const JsonCodec()});

  @override
  Converter<String, List<dynamic>> get decoder => JsonlDecoder(jsonCodec);

  @override
  Converter<List<dynamic>, String> get encoder => JsonlEncoder(jsonCodec);
}
