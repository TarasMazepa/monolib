/// Provides architectural utilities for aggregating, interleaving, and performing
/// cross-sequence mathematical operations on 2D collections (`Iterable<Iterable<T>>`).
///
/// This extension simplifies the orchestration of multiple distinct iterables,
/// allowing them to be processed as a single stream without manually managing
/// nested loops or multiple [Iterator] states. It is particularly useful for
/// time-series smoothing, batch result interleaving, or fair-scheduling algorithms.
extension OnIterableOfIterables<T> on Iterable<Iterable<T>> {
  /// Lazily interleaves elements from all child iterables in a round-robin fashion.
  ///
  /// The [mixed] getter iterates horizontally across the sequences. In each pass,
  /// it pulls one element from each active [Iterable]. When an [Iterable] is exhausted,
  /// it is safely removed from the rotation, and the interleaving continues with the
  /// remaining sequences until all are consumed.
  ///
  /// This is architecturally useful for fair-scheduling tasks or evenly merging
  /// paginated datasets where elements from different sources should be distributed
  /// uniformly.
  ///
  /// ```dart
  /// final queries = [
  ///   ['A1', 'A2', 'A3'],
  ///   ['B1'],
  ///   ['C1', 'C2'],
  /// ];
  ///
  /// // Yields: 'A1', 'B1', 'C1', 'A2', 'C2', 'A3'
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

  /// Lazily calculates the vertical average across all child iterables in lockstep.
  ///
  /// The [average] method iterates synchronously through all provided sequences,
  /// aggregating elements at the exact same index and dividing the sum by the total
  /// number of iterables to produce a single sequence of averages.
  ///
  /// Because it requires mathematical aggregation, the underlying elements `T` must
  /// support the `+` operator for addition and the `~/` (truncating division) operator.
  /// The operations are executed dynamically, making this suitable for types like `int`
  /// or custom numeric classes that implement these operators.
  ///
  /// It throws a [StateError] if the iterables are not of identical length, ensuring
  /// strict structural parity across the sequences being averaged.
  ///
  /// This is useful for smoothing time-series data or calculating row-wise means
  /// across multiple synchronized data channels.
  ///
  /// ```dart
  /// final sensorReads = [
  ///   [10, 20, 30],
  ///   [12, 22, 32],
  ///   [8, 18, 28],
  /// ];
  ///
  /// // Yields: 10, 20, 30 (e.g. (10+12+8)~/3 = 10)
  /// final smoothed = sensorReads.average().toList();
  /// ```
  Iterable<T> average() sync* {
    final iterators = map((iterable) => iterable.iterator).toList();

    /// Synchronously advances all underlying iterators.
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

    /// Dynamically divides the aggregated sum by the number of iterables.
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
