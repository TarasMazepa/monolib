import 'dart:convert';

class LineSplitterConverter extends Converter<String, String> {
  const LineSplitterConverter();

  @override
  String convert(String input) {
    return const LineSplitter().convert(input).join('\n');
  }

  @override
  Sink<String> startChunkedConversion(Sink<String> sink) {
    return const LineSplitter().startChunkedConversion(sink);
  }
}
