import 'dart:convert';

/// A Converter that parses JSON and maps to a strongly typed model,
/// dropping nulls along the way. Designed to be fused with LineSplitter.
class JsonlMapper<T> extends Converter<String, T> {
  final T? Function(dynamic) fromJson;
  final bool ignoreExceptions;

  const JsonlMapper(this.fromJson, {this.ignoreExceptions = false});

  @override
  T convert(String input) {
    throw UnsupportedError('This converter only supports chunked conversion');
  }

  @override
  Sink<String> startChunkedConversion(Sink<T> sink) {
    return _JsonlMapperSink<T>(sink, fromJson,
        ignoreExceptions: ignoreExceptions);
  }
}

class _JsonlMapperSink<T> implements ChunkedConversionSink<String> {
  final Sink<T> _outSink;
  final T? Function(dynamic) _fromJson;
  final bool ignoreExceptions;

  _JsonlMapperSink(this._outSink, this._fromJson,
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
