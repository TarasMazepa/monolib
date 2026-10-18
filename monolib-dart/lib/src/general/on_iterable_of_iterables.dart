/// Extension on [Iterable] of [Iterable]s that provides interleaving and
/// element-wise averaging.
extension OnIterableOfIterables<T> on Iterable<Iterable<T>> {
  /// Lazily interleaves elements from all child iterables in round-robin order.
  ///
  /// Pulls one element from each active child [Iterable] per pass. Exhausted
  /// iterables are removed from the rotation until all child iterables have
  /// been consumed.
  ///
  /// Example:
  /// ```dart
  /// final queries = [
  ///   ['A1', 'A2', 'A3'],
  ///   ['B1'],
  ///   ['C1', 'C2'],
  /// ];
  ///
  /// // ['A1', 'B1', 'C1', 'A2', 'C2', 'A3']
  /// final interleaved = queries.mixed.toList();
  /// ```
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

  /// Lazily computes the element-wise truncating average across all child
  /// iterables in lockstep.
  ///
  /// Sums the elements at each index using `+` and divides the sum by the
  /// number of child iterables using `~/`. Elements of type [T] must support
  /// both `+` and `~/`.
  ///
  /// Throws a [StateError] if the child iterables do not all have the same
  /// length.
  ///
  /// Example:
  /// ```dart
  /// final sensorReads = [
  ///   [10, 20, 30],
  ///   [12, 22, 32],
  ///   [8, 18, 28],
  /// ];
  ///
  /// // [10, 20, 30]
  /// final smoothed = sensorReads.average().toList();
  /// ```
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
      yield divide(sum, iterators.length);
    }
  }
}
