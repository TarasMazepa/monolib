import 'dart:convert';

/// A Converter that handles chunked string boundaries and parses JSON,
/// dropping nulls along the way. Emits raw dynamic objects.
class JsonlChunkedDecoder extends Converter<String, dynamic> {
  const JsonlChunkedDecoder();

  @override
  dynamic convert(String input) {
    throw UnsupportedError('This converter only supports chunked conversion');
  }

  @override
  Sink<String> startChunkedConversion(Sink<dynamic> sink) {
    return _JsonlChunkedDecoderSink(sink);
  }
}

class _JsonlChunkedDecoderSink implements ChunkedConversionSink<String> {
  final Sink<dynamic> _outSink;
  String _carry = '';

  _JsonlChunkedDecoderSink(this._outSink);

  void _processLine(String line) {
    if (line.endsWith('\r')) {
      line = line.substring(0, line.length - 1);
    }
    if (line.isNotEmpty) {
      final json = jsonDecode(line);
      if (json != null) {
        _outSink.add(json);
      }
    }
  }

  @override
  void add(String chunk) {
    int start = 0;
    while (true) {
      final newlineIndex = chunk.indexOf('\n', start);
      if (newlineIndex == -1) {
        _carry += chunk.substring(start);
        break;
      }
      String line = chunk.substring(start, newlineIndex);
      if (_carry.isNotEmpty) {
        line = _carry + line;
        _carry = '';
      }
      _processLine(line);
      start = newlineIndex + 1;
    }
  }

  @override
  void close() {
    if (_carry.isNotEmpty) {
      _processLine(_carry);
      _carry = '';
    }
    _outSink.close();
  }
}
