import 'dart:convert';

class CsvMappedDecoder<T> extends Converter<String, T> {
  final T? Function(List<String> row) mapper;

  const CsvMappedDecoder(this.mapper);

  @override
  T convert(String input) {
    throw UnsupportedError('This converter only supports chunked conversion');
  }

  @override
  Sink<String> startChunkedConversion(Sink<T> sink) {
    return _CsvRowDecoderSink<T>(sink, mapper);
  }
}

class _CsvRowDecoderSink<T> implements ChunkedConversionSink<String> {
  final Sink<T> _outSink;
  final T? Function(List<String> row) _mapper;

  bool _isInsideDoubleQuotes = false;
  List<String> _currentRow = [];
  int _previousChar = -1;
  String _carry = '';
  int _unprocessedTailLen = 0;

  _CsvRowDecoderSink(this._outSink, this._mapper);

  void _emitRow() {
    if (_currentRow.isNotEmpty) {
      final mapped = _mapper(_currentRow);
      if (mapped != null) {
        _outSink.add(mapped);
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
            _emitRow();
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
          _emitRow();
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
    _unprocessedTailLen = chunk.length - rightIndex;
  }

  @override
  void close() {
    if (_carry.isNotEmpty || _previousChar == 44) {
      final validCarry =
          _carry.substring(0, _carry.length - _unprocessedTailLen);
      if (_isInsideDoubleQuotes) {
        _currentRow.add(validCarry.replaceAll('""', '"'));
      } else {
        if (validCarry.isEmpty && _previousChar == 34) {
          // handled
        } else {
          _currentRow.add(validCarry);
        }
      }
      _carry = '';
    }
    _emitRow();
    _outSink.close();
  }
}
