extension OnMapper<T> on List<T> Function(List<T>) {
  Stream<List<T>> Function(Stream<List<T>>)
      get asSkippingMappedToEmptyExpander {
    List<List<T>> expander(List<T> list) {
      if (list.isEmpty) return [list];
      final result = this(list);
      if (result.isEmpty) return <List<T>>[];
      return [result];
    }

    return (s) => s.expand(expander);
  }
}
