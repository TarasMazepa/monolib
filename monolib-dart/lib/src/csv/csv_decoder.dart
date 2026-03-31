import 'dart:convert';

class CsvDecoder extends Converter<String, List<List<String>>> {
  const CsvDecoder();

  @override
  List<List<String>> convert(String items) {
    final sink = _CsvDecoderSink(null);
    sink.add(items);
    sink.close();
    return sink.result;
  }

  @override
  Sink<String> startChunkedConversion(Sink<List<List<String>>> sink) {
    return _CsvDecoderSink(sink);
  }
}

class _CsvDecoderSink implements ChunkedConversionSink<String> {
  final Sink<List<List<String>>>? _outSink;
  List<List<String>> result = [[]];

  int _leftIndex = 0;
  bool _isInsideDoubleQuotes = false;
  String _buffer = "";

  bool _lastCharWasComma = false;

  _CsvDecoderSink(this._outSink);

  @override
  void add(String chunk) {
    if (chunk.isEmpty) return;

    _buffer += chunk;
    int rightIndex = _leftIndex;

    while (rightIndex < _buffer.length) {
      final current = _buffer[rightIndex];
      _lastCharWasComma = (current == ',');

      if (_isInsideDoubleQuotes) {
        if (current == '"') {
          if (rightIndex < _buffer.length - 1) {
            if (_buffer[rightIndex + 1] == '"') {
              rightIndex += 2;
            } else {
              _isInsideDoubleQuotes = false;
              result.last.add(
                _buffer.substring(_leftIndex, rightIndex).replaceAll('""', '"'),
              );
              _leftIndex = rightIndex = rightIndex + 1;
            }
          } else {
            break; // Wait for next chunk to determine if quote is escaped
          }
        } else {
          rightIndex++;
        }
      } else {
        if (_leftIndex == rightIndex && current == '"') {
          _isInsideDoubleQuotes = true;
          _leftIndex++;
          rightIndex++;
        } else if (current == ',') {
          if (_leftIndex == rightIndex &&
              rightIndex > 0 &&
              _buffer[rightIndex - 1] == '"') {
            _leftIndex = rightIndex = rightIndex + 1;
          } else {
            result.last.add(_buffer.substring(_leftIndex, rightIndex));
            _leftIndex = rightIndex = rightIndex + 1;
          }
        } else if (current == '\r') {
          if (rightIndex < _buffer.length - 1) {
            if (_buffer[rightIndex + 1] == '\n') {
              if (_leftIndex != rightIndex ||
                  (rightIndex > 0 && _buffer[rightIndex - 1] == ',')) {
                result.last.add(_buffer.substring(_leftIndex, rightIndex));
              }

              if (_outSink != null) {
                _outSink!.add([result.last]);
                result = [[]];
              } else {
                result.add([]);
              }

              _leftIndex = rightIndex = rightIndex + 2;
              _lastCharWasComma = false;
            } else {
              rightIndex++;
            }
          } else {
            break; // Wait for next chunk to see if next char is \n
          }
        } else if (current == '\n') {
          if (_leftIndex != rightIndex ||
              (rightIndex > 0 && _buffer[rightIndex - 1] == ',')) {
            result.last.add(_buffer.substring(_leftIndex, rightIndex));
          }

          if (_outSink != null) {
            _outSink!.add([result.last]);
            result = [[]];
          } else {
            result.add([]);
          }

          _leftIndex = rightIndex = rightIndex + 1;
          _lastCharWasComma = false;
        } else {
          rightIndex++;
        }
      }
    }

    if (_leftIndex > 0) {
      _buffer = _buffer.substring(_leftIndex);
      _leftIndex = 0;
    }
  }

  @override
  void close() {
    int rightIndex = _buffer.length;

    if (_lastCharWasComma || _leftIndex != rightIndex) {
      if (_isInsideDoubleQuotes) {
        if (rightIndex > 0 && _buffer[rightIndex - 1] == '"') {
          result.last.add(
            _buffer.substring(_leftIndex, rightIndex - 1).replaceAll('""', '"'),
          );
        } else {
          result.last.add(
            _buffer.substring(_leftIndex, rightIndex).replaceAll('""', '"'),
          );
        }
      } else {
        result.last.add(_buffer.substring(_leftIndex, rightIndex));
      }
    }

    if (result.last.isEmpty) {
      result.removeLast();
    }

    if (_outSink != null && result.isNotEmpty) {
      _outSink!.add(result);
    }

    _outSink?.close();
  }
}
