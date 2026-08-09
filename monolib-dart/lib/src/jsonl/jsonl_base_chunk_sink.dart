import 'dart:convert';

abstract class JsonlBaseChunkSink<TOut>
    implements ChunkedConversionSink<String> {
  final Sink<TOut> outSink;
  String _carry = '';

  JsonlBaseChunkSink(this.outSink);

  void processLine(String line);

  void onChunkEnd() {}

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
      processLine(line);
      start = newlineIndex + 1;
    }
    onChunkEnd();
  }

  @override
  void close() {
    if (_carry.isNotEmpty) {
      processLine(_carry);
      _carry = '';
    }
    onChunkEnd();
    outSink.close();
  }
}
