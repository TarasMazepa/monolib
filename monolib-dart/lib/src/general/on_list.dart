extension OnList<T> on List<T> {
  T? elementAtOrNull(int index) {
    if (index >= length) return null;
    return this[index];
  }

  Iterable<T> drain() sync* {
    while (isNotEmpty) {
      yield removeLast();
    }
  }

  Iterable<R> drainMap<R>(R Function(T) mapper) sync* {
    while (isNotEmpty) {
      yield mapper(removeLast());
    }
  }

  List<E> toMappedList<E>(E Function(T) mapper, {bool growable = true}) =>
      List.generate(length, (i) => mapper(this[i]), growable: growable);

  List<E> toIndexedMappedList<E>(
    E Function(T, int index) mapper, {
    bool growable = true,
  }) => List.generate(length, (i) => mapper(this[i], i), growable: growable);

  int insertSorted(T element, {int Function(T a, T b)? compare}) {
    final comparator = compare ?? (a, b) => (a as Comparable).compareTo(b);
    int min = 0;
    int max = length;

    while (min < max) {
      final mid = min + ((max - min) >> 1);
      final item = this[mid];

      if (comparator(element, item) < 0) {
        max = mid;
      } else {
        min = mid + 1;
      }
    }

    insert(min, element);
    return min;
  }

  int? closestIndexOfTo(T element, int index) {
    if (this[index] == element) return index;
    int leftIndex = index - 1;
    int rightIndex = index + 1;
    while (0 <= leftIndex && rightIndex < length) {
      if (this[leftIndex] == element) return leftIndex;
      if (this[rightIndex] == element) return rightIndex;
      leftIndex--;
      rightIndex++;
    }
    while (leftIndex >= 0) {
      if (this[leftIndex] == element) return leftIndex;
      leftIndex--;
    }
    while (rightIndex < length) {
      if (this[rightIndex] == element) return rightIndex;
      rightIndex++;
    }
    return null;
  }
}
