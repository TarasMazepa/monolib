import 'dart:convert';

/// A base [ChunkedConversionSink] for chunked RFC 4180 CSV string decoding.
///
/// [CsvBaseChunkSink] ingests raw [String] chunks and parses them into
/// individual CSV rows (`List<String>`), handling fields wrapped in double
/// quotes containing internal line breaks, escaped quotes, and partial
/// (carry-over) chunks spanning multiple [add] calls.
///
/// Concrete decoders (such as [CsvChunkedDecoder], [CsvMappedDecoder], and
/// [CsvMappedBatchDecoder]) extend this class to delegate line and field
/// boundary scanning while implementing their own emission logic via
/// [handleRow] and [onChunkEnd].
///
/// Example:
/// ```dart
/// class MyStringCsvSink extends CsvBaseChunkSink<List<String>> {
///   MyStringCsvSink(super.outSink);
///
///   @override
///   void handleRow(List<String> row) {
///     outSink.add(row);
///   }
/// }
/// ```
abstract class CsvBaseChunkSink<TOut> implements ChunkedConversionSink<String> {
  /// The downstream sink that receives the processed outputs of type [TOut].
  final Sink<TOut> outSink;

  bool _isInsideDoubleQuotes = false;
  List<String> _currentRow = [];
  int _previousChar = -1;
  String _carry = '';
  int _unprocessedTailLen = 0;

  /// Creates a [CsvBaseChunkSink] that forwards processed outputs to [outSink].
  CsvBaseChunkSink(this.outSink);

  /// Invoked whenever a complete CSV [row] is parsed from the input stream.
  ///
  /// Subclasses must implement this method to process and emit the parsed [row]
  /// (for example, by forwarding it directly or mapping it into a domain object)
  /// to [outSink].
  void handleRow(List<String> row);

  /// A lifecycle hook invoked at the end of both [add] and [close].
  ///
  /// Batch-oriented subclasses (such as [CsvMappedBatchDecoder]) can override
  /// this method to flush buffered elements after a chunk of string data has
  /// been fully processed. By default, this method does nothing.
  void onChunkEnd() {}

  void _emitRow() {
    if (_currentRow.isNotEmpty) {
      handleRow(_currentRow);
      _currentRow = [];
    }
  }

  /// Ingests a raw [chunk] of CSV string data and advances the parser state.
  ///
  /// Scans through [chunk] to assemble fields and detect row boundaries.
  /// Incomplete trailing data is buffered internally and prepended to the next
  /// chunk on a subsequent call to [add]. Complete rows are dispatched to
  /// [handleRow], followed by [onChunkEnd] once the chunk is processed.
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

    onChunkEnd();
  }

  /// Finalizes parsing, flushes any remaining buffered data, and closes [outSink].
  ///
  /// Ensures that any trailing row without a final newline is parsed and
  /// emitted via [handleRow], invokes [onChunkEnd] one final time, and closes
  /// the downstream [outSink].
  @override
  void close() {
    if (_carry.isNotEmpty || _previousChar == 44) {
      final validCarry = _carry.substring(
        0,
        _carry.length - _unprocessedTailLen,
      );
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
    onChunkEnd();
    outSink.close();
  }
}
