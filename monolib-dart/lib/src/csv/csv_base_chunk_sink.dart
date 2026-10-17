/// Provides the core structural parsing and state management for stream-based CSV decoding.
///
/// This library centralizes the RFC 4180 parsing state machine, allowing various
/// chunked CSV decoders to share the same underlying logic for handling raw strings,
/// double-quoted fields, and multi-line breaks without duplicating code.
library;

import 'dart:convert';

/// An architectural base class for chunked CSV string decoding.
///
/// [CsvBaseChunkSink] acts as an intermediate state machine that ingests raw `String`
/// chunks and parses them into individual CSV rows (`List<String>`), handling complex
/// edge cases such as fields wrapped in double quotes containing internal line breaks,
/// escaped quotes, and partial (carry-over) chunks spanning multiple `add` calls.
///
/// By extending [CsvBaseChunkSink], concrete decoders (such as [CsvChunkedDecoder],
/// [CsvMappedDecoder], and [CsvMappedBatchDecoder]) can delegate the heavy lifting
/// of structural parsing to their internal sinks, focusing entirely on domain-specific
/// emission logic via [handleRow] and [onChunkEnd].
///
/// Example implementation:
/// ```dart
/// class MyStringCsvSink extends CsvBaseChunkSink<List<String>> {
///   MyStringCsvSink(super.outSink);
///
///   @override
///   void handleRow(List<String> row) {
///     // Emit the parsed row to the underlying output sink.
///     outSink.add(row);
///   }
/// }
/// ```
abstract class CsvBaseChunkSink<TOut> implements ChunkedConversionSink<String> {
  /// The underlying sink where transformed outputs of type [TOut] are emitted.
  ///
  /// Subclasses are expected to pass this during construction and use it within
  /// their [handleRow] or [onChunkEnd] implementations to forward the parsed results.
  final Sink<TOut> outSink;

  bool _isInsideDoubleQuotes = false;
  List<String> _currentRow = [];
  int _previousChar = -1;
  String _carry = '';
  int _unprocessedTailLen = 0;

  /// Initializes the sink with the destination [outSink].
  CsvBaseChunkSink(this.outSink);

  /// Invoked internally by the parser whenever a complete CSV [row] is finalized.
  ///
  /// Subclasses must implement this method to define how parsed rows are handled.
  /// For instance, a simple decoder might emit the raw [row] directly, while a
  /// mapped decoder might convert the [row] into a domain object before emitting.
  void handleRow(List<String> row);

  /// A lifecycle hook invoked at the conclusion of both [add] and [close].
  ///
  /// This method provides an opportunity for subclasses to perform batch emissions
  /// or cleanup tasks after a chunk of string data has been fully processed.
  /// By default, it does nothing and can be optionally overridden.
  void onChunkEnd() {}

  void _emitRow() {
    if (_currentRow.isNotEmpty) {
      handleRow(_currentRow);
      _currentRow = [];
    }
  }

  /// Ingests a raw [chunk] of CSV string data and drives the parsing state machine.
  ///
  /// This method iterates through the characters in [chunk], assembling fields and
  /// detecting row boundaries. If a row boundary is reached, it will trigger [handleRow].
  /// Incomplete data (e.g., a field cut off at the end of the chunk) is buffered internally
  /// and prepended to the next [chunk] in a subsequent call to [add].
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

  /// Finalizes parsing, flushes any remaining buffered data, and closes the output.
  ///
  /// This method ensures that trailing data or unfinished fields (such as a line without
  /// a trailing newline character) are fully parsed and emitted. Once flushed, it triggers
  /// [onChunkEnd] one last time and closes the [outSink].
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
