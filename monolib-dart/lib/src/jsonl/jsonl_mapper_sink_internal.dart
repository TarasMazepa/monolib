import 'dart:convert';

class JsonlMapperSinkInternal<T> implements ChunkedConversionSink<String> {
  final Sink<T> _outSink;
  final T? Function(dynamic) _fromJson;

  JsonlMapperSinkInternal(this._outSink, this._fromJson);

  @override
  void add(String chunk) {
    if (chunk.trim().isEmpty) return;

    // Parse and filter immediately in the chunk pipeline
    final json = jsonDecode(chunk);
    final mapped = _fromJson(json);
    if (mapped != null) {
      _outSink.add(mapped);
    }
  }

  @override
  void close() {
    _outSink.close();
  }
}
