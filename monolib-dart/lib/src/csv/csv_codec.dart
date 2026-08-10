import 'dart:convert';

import 'package:monolib_dart/src/csv/csv_decoder.dart';
import 'package:monolib_dart/src/csv/csv_encoder.dart';

class CsvCodec extends Codec<List<dynamic>, String> {
  @override
  late final Converter<List<dynamic>, String> encoder = const CsvEncoder();

  @override
  late final Converter<String, List<List<String>>> decoder = const CsvDecoder();
}
