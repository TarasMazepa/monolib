/// A mixin for accumulating individual decoded items into batched `List<T>`
/// chunks during stream transformations.
///
/// Batch stream decoders (such as `CsvMappedBatchDecoder` and
/// `JsonlMappedBatchDecoder`) process incoming string chunks record by record.
/// Instead of emitting every parsed record as a separate event, those decoders
/// use this mixin to buffer parsed items with [addToBatch] and emit them as a
/// single `List<T>` event via [flushBatchOnChunkEnd] at the end of each chunk.
///
/// Example:
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
  /// The downstream sink where batched lists of [T] are emitted.
  Sink<List<T>> get outSink;

  /// The internal buffer holding parsed items for the current incoming chunk.
  List<T> _batch = [];

  /// Appends a parsed [item] to the current batch buffer.
  void addToBatch(T item) {
    _batch.add(item);
  }

  /// Flushes the accumulated items into [outSink] as a single `List<T>` and
  /// resets the buffer for the next chunk.
  ///
  /// Does nothing if the current batch is empty.
  ///
  /// If [onBatch] is provided, it is invoked with the completed batch just
  /// before the batch is added to [outSink].
  void flushBatchOnChunkEnd({void Function(List<T> batch)? onBatch}) {
    if (_batch.isNotEmpty) {
      onBatch?.call(_batch);
      outSink.add(_batch);
      _batch = [];
    }
  }
}
