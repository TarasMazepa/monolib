/// Provides [BatchingSinkMixin], an architectural utility for buffering individual decoded items into distinct list chunks during stream processing.
library;

/// A mixin that abstracts the boilerplate required for accumulating individual items
/// into batched chunks during asynchronous stream transformations.
///
/// In this repository's data-parsing architecture, stream decoders (such as
/// `CsvMappedBatchDecoder` and `JsonlMappedBatchDecoder`) process incoming string
/// chunks line-by-line or record-by-record. Instead of emitting every single parsed
/// record as an isolated event—which can cause significant event loop overhead—these
/// decoders use this mixin to buffer parsed items and emit them as a single [List<T>]
/// event at the end of each incoming chunk.
///
/// This provides a clean separation of concerns: concrete chunk sinks only need to
/// focus on parsing payloads and calling [addToBatch] when a data item is ready.
/// Then, during their chunk lifecycle end (e.g., `onChunkEnd`), they invoke
/// [flushBatchOnChunkEnd] to handle list allocation and downstream emission.
///
/// Example usage within a custom decoder sink:
/// ```dart
/// class _MyMappedBatchSink<T> extends MyBaseChunkSink<List<T>>
///     with BatchingSinkMixin<T> {
///   _MyMappedBatchSink(super.outSink);
///
///   @override
///   void handleRecord(dynamic rawRecord) {
///     final mapped = _map(rawRecord);
///     if (mapped != null) {
///       addToBatch(mapped);
///     }
///   }
///
///   @override
///   void onChunkEnd() {
///     flushBatchOnChunkEnd();
///   }
/// }
/// ```
mixin BatchingSinkMixin<T> {
  /// The downstream target sink where batched lists of [T] will be emitted.
  ///
  /// Classes consuming this mixin must provide this sink, typically by passing
  /// the sink received from `startChunkedConversion` up to the base class
  /// or directly implementing it.
  Sink<List<T>> get outSink;

  /// The internal buffer holding parsed items for the current incoming chunk.
  List<T> _batch = [];

  /// Appends a newly parsed [item] to the internal batch buffer.
  ///
  /// Concrete chunk sinks should call this method for every successfully parsed
  /// or mapped item derived from the current incoming string chunk.
  void addToBatch(T item) {
    _batch.add(item);
  }

  /// Flushes the internally accumulated items into [outSink] as a single [List<T>]
  /// and resets the buffer for the next chunk.
  ///
  /// If the current batch is empty, this method performs no action, preventing
  /// the emission of empty lists downstream.
  ///
  /// The optional [onBatch] callback is invoked with the completed batch just before
  /// it is added to the downstream sink. This allows consumers to hook into the
  /// chunk emission lifecycle for side effects, such as logging or metrics,
  /// without manually intercepting the stream.
  void flushBatchOnChunkEnd({void Function(List<T> batch)? onBatch}) {
    if (_batch.isNotEmpty) {
      onBatch?.call(_batch);
      outSink.add(_batch);
      _batch = [];
    }
  }
}
