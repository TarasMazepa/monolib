import 'package:collection/collection.dart';

extension OnIterableIterable<T> on Iterable<Iterable<T>> {
  Iterable<T> mixSorted({int Function(T, T)? compare}) sync* {
    final effectiveCompare =
        compare ?? (a, b) => (a as Comparable).compareTo(b);
    final queue = PriorityQueue<Iterator<T>>(
      (a, b) => effectiveCompare(a.current, b.current),
    );

    for (final iterable in this) {
      final iterator = iterable.iterator;
      if (iterator.moveNext()) {
        queue.add(iterator);
      }
    }

    while (queue.isNotEmpty) {
      final iterator = queue.removeFirst();
      final current = iterator.current;

      yield current;

      if (iterator.moveNext()) {
        queue.add(iterator);
      }
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
