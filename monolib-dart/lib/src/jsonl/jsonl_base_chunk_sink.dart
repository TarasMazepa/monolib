import 'dart:convert';

/// An architectural base class providing the structural parsing engine and state
/// machine for chunked JSON Lines (JSONL) ingestion.
///
/// [JsonlBaseChunkSink] implements the [ChunkedConversionSink] interface to
/// process raw, fragmented `String` chunks directly from a stream. It is designed
/// to bypass the intermediate stream event overhead typical of Dart's standard
/// `LineSplitter` by autonomously scanning for newline boundaries, buffering
/// incomplete lines across discrete stream events in an internal state, and
/// normalizing carriage returns.
///
/// Once a complete, sanitized line is extracted, it delegates the actual JSON
/// decoding and domain object mapping to concrete subclasses via the abstract
/// [processLine] hook (e.g., `_JsonlMappedDecoderSink` in `JsonlMappedDecoder`).
///
/// Example architecture usage by a subclass:
/// ```dart
/// class MyDecoderSink extends JsonlBaseChunkSink<Map<String, dynamic>> {
///   MyDecoderSink(super.outSink);
///
///   @override
///   void processLine(String line) {
///     final json = jsonDecode(line);
///     outSink.add(json);
///   }
/// }
/// ```
abstract class JsonlBaseChunkSink<TOut>
    implements ChunkedConversionSink<String> {
  /// The downstream destination sink that receives the fully processed output
  /// instances of type [TOut] (such as parsed domain objects or lists).
  final Sink<TOut> outSink;
  String _carry = '';

  /// Constructs a [JsonlBaseChunkSink] that pipes its final, mapped outputs
  /// into the provided [outSink].
  JsonlBaseChunkSink(this.outSink);

  /// An abstract hook invoked by the structural parser whenever a complete,
  /// sanitized JSON line string is successfully extracted from the stream chunk.
  ///
  /// Subclasses must implement this method to handle the actual JSON decoding
  /// and mapping for the [line], eventually dispatching results to the [outSink].
  void processLine(String line);

  /// An optional lifecycle hook invoked immediately after a discrete stream chunk
  /// has been fully parsed into lines.
  ///
  /// This is leveraged by batch-oriented subclasses (like
  /// `_JsonlMappedBatchDecoderSink`) to flush intermediate states or buffered
  /// elements once a chunk boundary is reached, optimizing asynchronous batching.
  void onChunkEnd() {}

  void _handleRawLine(String line) {
    if (line.endsWith('\r')) {
      line = line.substring(0, line.length - 1);
    }
    if (line.isNotEmpty) {
      processLine(line);
    }
  }

  /// Consumes a raw string [chunk] from the upstream source.
  ///
  /// This method iterates through the [chunk], isolating individual lines by
  /// newline boundaries (`\n`). If a previous chunk ended prematurely, its
  /// incomplete trailing string is seamlessly prepended to the first line. Any
  /// trailing incomplete string in the current chunk is buffered in memory for
  /// the subsequent chunk. Complete lines are dispatched to [processLine].
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

  /// Finalizes the stream ingestion process.
  ///
  /// Flushes any unsent, incomplete string data buffered from previous chunks
  /// (simulating a final newline), triggers a final [onChunkEnd] lifecycle
  /// event, and gracefully shuts down the downstream [outSink].
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
