import 'dart:convert';

import 'package:monolib_dart/monolib_dart.dart';

class JsonlDecoder extends Converter<String, List<dynamic>> {
  final Codec<Object?, String> jsonCodec;

  const JsonlDecoder(this.jsonCodec);

  @override
  List<dynamic> convert(String items) {
    final result = [];
    int left = 0;
    int? indexOfNextNewLine() {
      if (left >= items.length) {
        return null;
      }
      return items.indexOf('\n', left).asNullableIndex;
    }

    int? right = indexOfNextNewLine();
    while (left < items.length && (right == null || left <= right)) {
      try {
        result.add(jsonCodec.decode(items.substring(left, right)));
        left = switch (right) {
          null => items.length,
          final index => index + 1,
        };
        right = indexOfNextNewLine();
      } catch (_) {
        left = indexOfNextNewLine() ?? items.length;
        left++;
        right = indexOfNextNewLine();
      }
    }
    return result;
  }
}
