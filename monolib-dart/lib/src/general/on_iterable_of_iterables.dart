extension OnIterableOfIterables<T> on Iterable<Iterable<T>> {
  Iterable<T> get mixed sync* {
    final iterators = map(
      (iterable) => iterable.iterator,
    ).toList(growable: true);
    while (iterators.isNotEmpty) {
      for (int i = 0; i < iterators.length;) {
        final iterator = iterators[i];
        if (iterator.moveNext()) {
          yield iterator.current;
          i++;
        } else {
          iterators.removeAt(i);
        }
      }
    }
  }
}
