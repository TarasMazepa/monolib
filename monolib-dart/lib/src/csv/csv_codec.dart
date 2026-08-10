import 'dart:convert';

import 'package:monolib_dart/src/csv/csv_decoder.dart';
import 'package:monolib_dart/src/csv/csv_encoder.dart';

class CsvCodec extends Codec<List<dynamic>, String> {
  const CsvCodec();

  @override
  Converter<List<dynamic>, String> get encoder => const CsvEncoder();

  @override
  Converter<String, List<List<String>>> get decoder => const CsvDecoder();
}
