class ListAccumulatorSink<T> implements Sink<T> {
  final List<T> results = [];

  @override
  void add(T data) {
    results.add(data);
  }

  @override
  void close() {}
}
