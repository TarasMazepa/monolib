/// Extension on [List] that provides draining, eager mapping, binary-search
/// insertion, and formatting utilities.
extension OnList<T> on List<T> {
  /// Lazily removes and yields elements from the end of this list until it is
  /// empty.
  ///
  /// Removes elements using [removeLast] to avoid the shifting overhead of
  /// removing from the front of a [List].
  ///
  /// Example:
  /// ```dart
  /// final queue = [1, 2, 3];
  /// for (final item in queue.drain()) {
  ///   print(item); // 3, 2, 1
  /// }
  /// print(queue.isEmpty); // true
  /// ```
  Iterable<T> drain() sync* {
    while (isNotEmpty) {
      yield removeLast();
    }
  }

  /// Lazily removes elements from the end of this list and yields the result of
  /// applying [mapper] to each removed element.
  ///
  /// Because the returned [Iterable] is lazy, elements are only removed from
  /// this list as the returned sequence is iterated.
  ///
  /// Example:
  /// ```dart
  /// final queue = [1, 2, 3];
  /// final doubled = queue.drainMap((x) => x * 2).toList(); // [6, 4, 2]
  /// print(queue.isEmpty); // true
  /// ```
  Iterable<R> drainMap<R>(R Function(T) mapper) sync* {
    while (isNotEmpty) {
      yield mapper(removeLast());
    }
  }

  /// Eagerly maps each element of this list using [mapper] and returns a new
  /// [List].
  ///
  /// Pre-allocates the result list to [length] via [List.generate]. Whether the
  /// returned list is growable is controlled by [growable].
  ///
  /// Example:
  /// ```dart
  /// final stringIds = [1, 2, 3].toMappedList(
  ///   (id) => id.toString(),
  ///   growable: false,
  /// );
  /// ```
  List<E> toMappedList<E>(E Function(T) mapper, {bool growable = true}) =>
      List.generate(length, (i) => mapper(this[i]), growable: growable);

  /// Eagerly maps each element and its index using [mapper] and returns a new
  /// [List].
  ///
  /// Pre-allocates the result list to [length] via [List.generate]. Whether the
  /// returned list is growable is controlled by [growable].
  ///
  /// Example:
  /// ```dart
  /// final labels = ['a', 'b'].toIndexedMappedList(
  ///   (item, index) => '$index: $item',
  /// ); // ['0: a', '1: b']
  /// ```
  List<E> toIndexedMappedList<E>(
    E Function(T, int index) mapper, {
    bool growable = true,
  }) =>
      List.generate(length, (i) => mapper(this[i], i), growable: growable);

  /// Inserts [element] into this sorted list while preserving its sorted order,
  /// and returns the insertion index.
  ///
  /// Uses binary search (`O(log n)`) to find the insertion index. If [compare]
  /// is omitted, elements must implement [Comparable].
  ///
  /// Example:
  /// ```dart
  /// final times = [10, 30, 50];
  /// times.insertSorted(20); // times is [10, 20, 30, 50]
  /// ```
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

  /// Searches outward in both directions from [index] and returns the index of
  /// the nearest occurrence of [element], or `null` if not found.
  ///
  /// Example:
  /// ```dart
  /// final values = ['A', 'B', 'C', 'B', 'A'];
  /// final matchIndex = values.closestIndexOfTo('B', 2); // 1
  /// ```
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

  /// Returns `true` if this list and [other] have the same length and equal
  /// elements at every index.
  ///
  /// Example:
  /// ```dart
  /// final listA = [1, 2];
  /// final listB = [1, 2];
  /// print(listA.deepEquals(listB)); // true
  /// ```
  bool deepEquals(List<T> other) {
    if (identical(this, other)) return true;
    if (length != other.length) return false;
    for (int index = 0; index < length; index++) {
      if (this[index] != other[index]) return false;
    }
    return true;
  }

  /// Joins the elements of this list into a string separated by [delimiter] and
  /// enclosed by [prefix] and [suffix].
  ///
  /// If [map] is provided, each element is converted with [map] before joining.
  /// If this list is empty and [ifEmpty] is provided, returns the result of
  /// calling [ifEmpty] without [prefix] or [suffix].
  ///
  /// Example:
  /// ```dart
  /// final result = [1, 2].joinWith(
  ///   prefix: '[',
  ///   delimiter: ', ',
  ///   suffix: ']',
  /// ); // '[1, 2]'
  /// ```
  String joinWith({
    String prefix = '',
    String delimiter = '',
    String suffix = '',
    String Function(T)? map,
    String Function()? ifEmpty,
  }) {
    if (isEmpty && ifEmpty != null) return ifEmpty();

    final Iterable<dynamic> iterable = map != null ? this.map(map) : this;
    return '$prefix${iterable.join(delimiter)}$suffix';
  }
}
