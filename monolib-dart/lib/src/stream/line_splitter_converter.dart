import 'dart:convert';

class LineSplitterConverter extends Converter<String, String> {
  const LineSplitterConverter();

  @override
  String convert(String input) {
    throw UnsupportedError('This converter only supports chunked conversion');
  }

  @override
  Sink<String> startChunkedConversion(Sink<String> sink) {
    return const LineSplitter().startChunkedConversion(sink);
  }
}
