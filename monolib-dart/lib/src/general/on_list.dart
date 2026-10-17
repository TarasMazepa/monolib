/// Provides architectural utility methods and mutation patterns for [List] collections.
///
/// This extension centralizes common operations such as destructive read access
/// ([drain], [drainMap]), memory-optimized transformations ([toMappedList]), and
/// binary search mutations ([insertSorted]). These utilities prevent scattered
/// list manipulation logic across the domain and provide optimized alternatives
/// to native iterable operations, especially for performance-sensitive iterations.
library;

/// Supplements the core [List] type with domain-specific collection utilities.
///
/// [OnList] exposes destructive extraction methods, optimized mapping functions
/// that skip intermediate iterables, and specialized element positioning tools.
extension OnList<T> on List<T> {
  /// Destructively consumes the list by repeatedly removing and yielding its last element.
  ///
  /// This provides an efficient way to clear a collection while sequentially processing
  /// its contents, acting as an active pipeline rather than a passive iterator.
  /// Because elements are removed from the end, it avoids the memory shifting overhead
  /// associated with removing elements from the start of a [List].
  ///
  /// ```dart
  /// final queue = [1, 2, 3];
  /// for (final item in queue.drain()) {
  ///   print(item); // Prints 3, 2, 1
  /// }
  /// print(queue.isEmpty); // true
  /// ```
  Iterable<T> drain() sync* {
    while (isNotEmpty) {
      yield removeLast();
    }
  }

  /// Destructively consumes the list and immediately applies a [mapper] to each element.
  ///
  /// Similar to [drain], this removes elements from the end of the list but
  /// seamlessly converts them to a new type [R] during extraction. It prevents
  /// creating a separate mapping operation over a drained iterable.
  ///
  /// ```dart
  /// final pendingSubscriptions = [sub1, sub2];
  /// final unsubscriptions = pendingSubscriptions.drainMap((s) => s.cancel());
  /// ```
  Iterable<R> drainMap<R>(R Function(T) mapper) sync* {
    while (isNotEmpty) {
      yield mapper(removeLast());
    }
  }

  /// Eagerly converts the list to a new mapped [List] using [List.generate].
  ///
  /// Unlike standard `map().toList()`, which involves intermediate lazy iterables
  /// and potentially unoptimized list growing, [toMappedList] allocates the correct
  /// capacity immediately by using the current list's length.
  ///
  /// The [growable] parameter dictates whether the newly created list can change length.
  ///
  /// ```dart
  /// final stringIds = [1, 2, 3].toMappedList((id) => id.toString(), growable: false);
  /// ```
  List<E> toMappedList<E>(E Function(T) mapper, {bool growable = true}) =>
      List.generate(length, (i) => mapper(this[i]), growable: growable);

  /// Eagerly converts the list to a new mapped [List], providing the current index to the [mapper].
  ///
  /// Avoids the overhead of `asMap().entries.map(...)` by directly utilizing a
  /// [List.generate] loop. Useful for index-aware transformations.
  ///
  /// The [growable] parameter dictates whether the newly created list can change length.
  ///
  /// ```dart
  /// final widgets = items.toIndexedMappedList((item, index) {
  ///   return buildItem(item, isFirst: index == 0);
  /// });
  /// ```
  List<E> toIndexedMappedList<E>(
    E Function(T, int index) mapper, {
    bool growable = true,
  }) =>
      List.generate(length, (i) => mapper(this[i], i), growable: growable);

  /// Inserts the [element] into a naturally sorted list, maintaining its sorted order.
  ///
  /// Uses a binary search algorithm to quickly find the correct insertion point
  /// (`O(log n)` time), significantly outperforming linear insertions on large lists.
  ///
  /// If [compare] is not provided, elements must implement [Comparable]. Returns
  /// the index where the [element] was inserted.
  ///
  /// ```dart
  /// final times = [10, 30, 50];
  /// times.insertSorted(20); // times becomes [10, 20, 30, 50]
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

  /// Locates the [element] by expanding outwards from the specified starting [index].
  ///
  /// Instead of a sequential scan from the beginning, this method searches bidirectionally.
  /// It is highly optimized for scenarios where an element is expected to be near
  /// a known vicinity (e.g., matching a localized cluster in a visual list).
  ///
  /// Returns the index of the [element], or `null` if it is not found in the list.
  ///
  /// ```dart
  /// final values = ['A', 'B', 'C', 'B', 'A'];
  /// // Searches outward starting from index 2 ('C').
  /// final matchIndex = values.closestIndexOfTo('B', 2); // returns 1 or 3
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

  /// Performs a structural equality check against [other].
  ///
  /// Unlike standard [List] equality which checks identity, [deepEquals] iterates
  /// through all items to verify both lists contain identically ordered elements.
  /// It employs early exit checks for identity and length to optimize performance.
  ///
  /// ```dart
  /// final listA = [1, 2];
  /// final listB = [1, 2];
  /// print(listA == listB); // false
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

  /// Stringifies and joins list elements into a fully constructed string representation.
  ///
  /// Acts as a cohesive formatter that surrounds the joined elements with a [prefix]
  /// and [suffix]. It optionally maps elements using [map] before joining them
  /// with a [delimiter].
  ///
  /// If the list is empty and an [ifEmpty] fallback is provided, it returns the
  /// result of [ifEmpty], ignoring the prefix and suffix.
  ///
  /// ```dart
  /// final arrayStr = [1, 2].joinWith(
  ///   prefix: '[',
  ///   delimiter: ', ',
  ///   suffix: ']',
  /// ); // Returns '[1, 2]'
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
