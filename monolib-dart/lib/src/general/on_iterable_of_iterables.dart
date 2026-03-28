extension OnIterableOfIterables<T> on Iterable<Iterable<T>> {
  Iterable<T> get mixed sync* {
    final iterators = map(
      (iterable) => iterable.iterator,
    ).toList(growable: true);
    while (iterators.isNotEmpty) {
      int activeCount = 0;
      for (int i = 0; i < iterators.length; i++) {
        final iterator = iterators[i];
        if (iterator.moveNext()) {
          yield iterator.current;
          iterators[activeCount++] = iterator;
        }
      }
      iterators.length = activeCount;
    }
  }

  Iterable<T> average() sync* {
    final iterators = map((iterable) => iterable.iterator).toList();
    bool moveNext() {
      bool any = false;
      bool all = true;
      for (final iterator in iterators) {
        final moveNext = iterator.moveNext();
        any |= moveNext;
        all &= moveNext;
        if (any && !all) {
          throw StateError('Different length iterables');
        }
      }
      return all;
    }

    T divide(dynamic what, dynamic divisor) {
      return what ~/ divisor;
    }

    while (moveNext()) {
      dynamic sum = iterators.first.current;
      for (int i = 1; i < iterators.length; i++) {
        sum += iterators[i].current;
      }
      yield divide(
        sum,
        iterators.length,
      );
    }
  }
}
