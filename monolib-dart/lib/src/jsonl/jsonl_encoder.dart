import 'dart:convert';

class JsonlEncoder extends Converter<List<dynamic>, String> {
  final Codec<Object?, String> jsonCodec;

  const JsonlEncoder(this.jsonCodec);

  @override
  String convert(List<dynamic> items) {
    final result = StringBuffer();
    for (final item in items) {
      result.writeln(jsonCodec.encode(item));
    }
    return result.toString();
  }
}
