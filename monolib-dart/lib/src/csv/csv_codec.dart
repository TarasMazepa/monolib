import 'dart:convert';

import 'csv_decoder.dart';
import 'csv_encoder.dart';

class CsvCodec extends Codec<List<dynamic>, String> {
  const CsvCodec();

  @override
  Converter<List<dynamic>, String> get encoder => const CsvEncoder();

  @override
  Converter<String, List<List<String>>> get decoder => const CsvDecoder();
}
