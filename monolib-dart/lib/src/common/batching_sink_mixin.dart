mixin BatchingSinkMixin<T> {
  Sink<List<T>> get outSink;

  List<T> _batch = [];

  void addToBatch(T item) {
    _batch.add(item);
  }

  void flushBatchOnChunkEnd({void Function(List<T> batch)? onBatch}) {
    if (_batch.isNotEmpty) {
      onBatch?.call(_batch);
      outSink.add(_batch);
      _batch = [];
    }
  }
}
