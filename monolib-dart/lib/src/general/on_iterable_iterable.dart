extension OnIterableIterable<T> on Iterable<Iterable<T>> {
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
      dynamic currentSum;
      bool isFirst = true;
      for (final iterator in iterators) {
        if (isFirst) {
          currentSum = iterator.current;
          isFirst = false;
        } else {
          currentSum += iterator.current;
        }
      }
      yield divide(currentSum, iterators.length);
    }
  }

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
