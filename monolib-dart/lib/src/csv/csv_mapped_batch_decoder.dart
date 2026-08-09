import 'dart:convert';

class CsvMappedBatchDecoder<T> extends Converter<String, List<T>> {
  final T? Function(List<String> row) mapper;

  const CsvMappedBatchDecoder(this.mapper);

  @override
  List<T> convert(String input) {
    throw UnsupportedError('This converter only supports chunked conversion');
  }

  @override
  Sink<String> startChunkedConversion(Sink<List<T>> sink) {
    return _CsvBatchDecoderSink<T>(sink, mapper);
  }
}

class _CsvBatchDecoderSink<T> implements ChunkedConversionSink<String> {
  final Sink<List<T>> _outSink;
  final T? Function(List<String> row) _mapper;

  bool _isInsideDoubleQuotes = false;
  List<String> _currentRow = [];
  int _previousChar = -1;
  String _carry = '';

  _CsvBatchDecoderSink(this._outSink, this._mapper);

  void _emitRow(List<T> batch) {
    if (_currentRow.isNotEmpty) {
      final mapped = _mapper(_currentRow);
      if (mapped != null) {
        batch.add(mapped);
      }
      _currentRow = [];
    }
  }

  @override
  void add(String chunk) {
    if (chunk.isEmpty) return;

    if (_carry.isNotEmpty) {
      chunk = _carry + chunk;
      _carry = '';
    }

    final batch = <T>[];
    int leftIndex = 0;
    int rightIndex = 0;

    int getPrevChar() {
      if (rightIndex > 0) {
        return chunk.codeUnitAt(rightIndex - 1);
      } else {
        return _previousChar;
      }
    }

    while (rightIndex < chunk.length) {
      final current = chunk.codeUnitAt(rightIndex);

      if (_isInsideDoubleQuotes) {
        if (current == 34 /* '"' */) {
          if (rightIndex < chunk.length - 1 &&
              chunk.codeUnitAt(rightIndex + 1) == 34) {
            rightIndex += 2;
          } else if (rightIndex == chunk.length - 1) {
            break;
          } else {
            _isInsideDoubleQuotes = false;
            _currentRow.add(
              chunk.substring(leftIndex, rightIndex).replaceAll('""', '"'),
            );
            leftIndex = rightIndex = rightIndex + 1;
          }
        } else {
          rightIndex++;
        }
      } else {
        if (leftIndex == rightIndex && current == 34) {
          _isInsideDoubleQuotes = true;
          leftIndex++;
          rightIndex++;
        } else if (current == 44 /* ',' */) {
          if (leftIndex == rightIndex && getPrevChar() == 34) {
            leftIndex = rightIndex = rightIndex + 1;
          } else {
            _currentRow.add(chunk.substring(leftIndex, rightIndex));
            leftIndex = rightIndex = rightIndex + 1;
          }
        } else if (current == 13 /* '\r' */) {
          if (rightIndex < chunk.length - 1 &&
              chunk.codeUnitAt(rightIndex + 1) == 10 /* '\n' */) {
            if (leftIndex != rightIndex || getPrevChar() == 44) {
              _currentRow.add(chunk.substring(leftIndex, rightIndex));
            }
            _emitRow(batch);
            leftIndex = rightIndex = rightIndex + 2;
          } else if (rightIndex == chunk.length - 1) {
            break;
          } else {
            rightIndex++;
          }
        } else if (current == 10 /* '\n' */) {
          if (leftIndex != rightIndex || getPrevChar() == 44) {
            _currentRow.add(chunk.substring(leftIndex, rightIndex));
          }
          _emitRow(batch);
          leftIndex = rightIndex = rightIndex + 1;
        } else {
          rightIndex++;
        }
      }
    }

    if (leftIndex > 0) {
      _previousChar = chunk.codeUnitAt(leftIndex - 1);
    }
    _carry = chunk.substring(leftIndex);

    if (batch.isNotEmpty) {
      _outSink.add(batch);
    }
  }

  @override
  void close() {
    final batch = <T>[];
    if (_carry.isNotEmpty || _previousChar == 44) {
      if (_isInsideDoubleQuotes) {
        _currentRow.add(_carry.replaceAll('""', '"'));
      } else {
        if (_carry.isEmpty && _previousChar == 34) {
          // handled
        } else {
          _currentRow.add(_carry);
        }
      }
      _carry = '';
    }
    _emitRow(batch);
    if (batch.isNotEmpty) {
      _outSink.add(batch);
    }
    _outSink.close();
  }
}
