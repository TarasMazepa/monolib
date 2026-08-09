import 'dart:convert';
import '../common/chunked_only_converter.dart';

/// A Converter that fuses line-splitting directly into JSON mapping,
/// avoiding the stream event overhead of LineSplitterConverter.
class JsonlMappedDecoder<T> extends ChunkedOnlyConverter<String, T> {
  final T? Function(dynamic) fromJson;
  final bool ignoreExceptions;

  const JsonlMappedDecoder(this.fromJson, {this.ignoreExceptions = false});

  @override
  Sink<String> startChunkedConversion(Sink<T> sink) {
    return _JsonlMappedDecoderSink<T>(
      sink,
      fromJson,
      ignoreExceptions: ignoreExceptions,
    );
  }
}

class _JsonlMappedDecoderSink<T> implements ChunkedConversionSink<String> {
  final Sink<T> _outSink;
  final T? Function(dynamic) _fromJson;
  final bool ignoreExceptions;
  String _carry = '';

  _JsonlMappedDecoderSink(
    this._outSink,
    this._fromJson, {
    this.ignoreExceptions = false,
  });

  void _processLine(String line) {
    if (line.endsWith('\r')) {
      line = line.substring(0, line.length - 1);
    }
    if (line.isNotEmpty) {
      try {
        final json = jsonDecode(line);
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
