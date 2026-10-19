import 'dart:convert';

/// A base [ChunkedConversionSink] for chunked JSON Lines (JSONL) string decoding.
///
/// [JsonlBaseChunkSink] ingests raw [String] chunks and splits them into
/// individual JSON lines along newline boundaries (`\n` or `\r\n`), buffering
/// incomplete trailing chunks across multiple [add] calls and skipping empty
/// lines.
///
/// Concrete decoders (such as [JsonlChunkedDecoder], [JsonlMappedDecoder], and
/// [JsonlMappedBatchDecoder]) extend this class to delegate line boundary
/// scanning while implementing their own decoding and emission logic via
/// [processLine] and [onChunkEnd].
///
/// Example:
/// ```dart
/// class MyDecoderSink extends JsonlBaseChunkSink<Map<String, dynamic>> {
///   MyDecoderSink(super.outSink);
///
///   @override
///   void processLine(String line) {
///     final json = jsonDecode(line) as Map<String, dynamic>;
///     outSink.add(json);
///   }
/// }
/// ```
abstract class JsonlBaseChunkSink<TOut>
    implements ChunkedConversionSink<String> {
  /// The downstream sink that receives the processed outputs of type [TOut].
  final Sink<TOut> outSink;
  String _carry = '';

  /// Creates a [JsonlBaseChunkSink] that forwards processed outputs to [outSink].
  JsonlBaseChunkSink(this.outSink);

  /// Invoked whenever a complete, non-empty JSON [line] is extracted from the input stream.
  ///
  /// Subclasses must implement this method to decode and emit the parsed [line]
  /// (for example, by forwarding the decoded JSON or mapping it into a domain
  /// object) to [outSink].
  void processLine(String line);

  /// A lifecycle hook invoked at the end of both [add] and [close].
  ///
  /// Batch-oriented subclasses (such as [JsonlMappedBatchDecoder]) can override
  /// this method to flush buffered elements after a chunk of string data has
  /// been fully processed. By default, this method does nothing.
  void onChunkEnd() {}

  void _handleRawLine(String line) {
    if (line.endsWith('\r')) {
      line = line.substring(0, line.length - 1);
    }
    if (line.isNotEmpty) {
      processLine(line);
    }
  }

  /// Ingests a raw [chunk] of JSONL string data and advances the parser state.
  ///
  /// Scans through [chunk] to isolate lines separated by `\n`. Incomplete
  /// trailing data is buffered internally and prepended to the next chunk on a
  /// subsequent call to [add]. Complete non-empty lines are dispatched to
  /// [processLine], followed by [onChunkEnd] once the chunk is processed.
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
      _handleRawLine(line);
      start = newlineIndex + 1;
    }
    onChunkEnd();
  }

  /// Finalizes parsing, flushes any remaining buffered data, and closes [outSink].
  ///
  /// Ensures that any trailing line without a final newline is processed via
  /// [processLine], invokes [onChunkEnd] one final time, and closes the
  /// downstream [outSink].
  @override
  void close() {
    if (_carry.isNotEmpty) {
      _handleRawLine(_carry);
      _carry = '';
    }
    onChunkEnd();
    outSink.close();
  }
}
