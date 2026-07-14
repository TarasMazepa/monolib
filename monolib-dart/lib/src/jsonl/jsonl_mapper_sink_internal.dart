import 'dart:convert';

class JsonlMapperSinkInternal<T> implements ChunkedConversionSink<String> {
  final Sink<T> _outSink;
  final T? Function(dynamic) _fromJson;
  final bool ignoreExceptions;

  JsonlMapperSinkInternal(this._outSink, this._fromJson,
      {this.ignoreExceptions = false});

  @override
  void add(String chunk) {
    try {
      // Parse and filter immediately in the chunk pipeline
      final json = jsonDecode(chunk);
      final mapped = _fromJson(json);
      if (mapped != null) {
        _outSink.add(mapped);
      }
    } catch (e) {
      if (!ignoreExceptions) {
        rethrow;
      }
    }
  }

  @override
  void close() {
    _outSink.close();
  }
}
