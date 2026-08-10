mixin BatchingSinkMixin<T> {
  Sink<List<T>> get outSink;

  List<T> _batch = [];

  void addToBatch(T item) {
    _batch.add(item);
  }

  void flushBatchOnChunkEnd() {
    if (_batch.isNotEmpty) {
      outSink.add(_batch);
      _batch = [];
    }
  }
}
