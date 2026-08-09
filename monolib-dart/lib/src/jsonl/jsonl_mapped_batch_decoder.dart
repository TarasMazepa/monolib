import 'dart:convert';
import '../common/chunked_only_converter.dart';

class JsonlMappedBatchDecoder<T> extends ChunkedOnlyConverter<String, List<T>> {
  final T? Function(dynamic) fromJson;
  final bool ignoreExceptions;

  const JsonlMappedBatchDecoder(this.fromJson, {this.ignoreExceptions = false});

  @override
  Sink<String> startChunkedConversion(Sink<List<T>> sink) {
    return _JsonlMappedBatchDecoderSink<T>(
      sink,
      fromJson,
      ignoreExceptions: ignoreExceptions,
    );
  }
}

class _JsonlMappedBatchDecoderSink<T> implements ChunkedConversionSink<String> {
  final Sink<List<T>> _outSink;
  final T? Function(dynamic) _fromJson;
  final bool ignoreExceptions;
  String _carry = '';

  _JsonlMappedBatchDecoderSink(
    this._outSink,
    this._fromJson, {
    this.ignoreExceptions = false,
  });

  void _processLine(String line, List<T> batch) {
    if (line.endsWith('\r')) {
      line = line.substring(0, line.length - 1);
    }
    if (line.isNotEmpty) {
      try {
        final json = jsonDecode(line);
        final mapped = _fromJson(json);
        if (mapped != null) {
          batch.add(mapped);
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
    final batch = <T>[];
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
      _processLine(line, batch);
      start = newlineIndex + 1;
    }

    if (batch.isNotEmpty) {
      _outSink.add(batch);
    }
  }

  @override
  void close() {
    if (_carry.isNotEmpty) {
      final batch = <T>[];
      _processLine(_carry, batch);
      if (batch.isNotEmpty) {
        _outSink.add(batch);
      }
      _carry = '';
    }
    _outSink.close();
  }
}
