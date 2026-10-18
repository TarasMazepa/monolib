import 'package:monolib_dart/src/general/on_empty_iterable.dart';

/// Extension on [Iterable] that provides emptiness callbacks and summation
/// utilities.
extension OnIterable<T> on Iterable<T> {
  /// Returns a lazy [OnEmptyIterable] that invokes [onEmpty] when iterating
  /// this sequence yields no elements.
  ///
  /// Detects emptiness during iteration rather than calling [Iterable.isEmpty]
  /// up front, avoiding extra passes over lazy or single-subscription
  /// sequences.
  ///
  /// Example:
  /// ```dart
  /// final metrics = <int>[].onEmpty(() {
  ///   print('No metrics collected.');
  /// });
  ///
  /// for (final stat in metrics) {
  ///   print(stat);
  /// }
  /// ```
  Iterable<T> onEmpty(void Function() onEmpty) {
    return OnEmptyIterable(this, onEmpty);
  }

  /// Sums all elements in this iterable using dynamic dispatch of the `+`
  /// operator.
  ///
  /// If the iterable is empty, returns [zero] when provided, or automatically
  /// returns `0` / `0.0` when [T] is [int], [double], or [num].
  ///
  /// Throws a [StateError] if the iterable is empty and no fallback value can
  /// be determined.
  ///
  /// Example:
  /// ```dart
  /// final expenses = <double>[15.50, 42.0, 9.99];
  /// final total = expenses.sum(); // 67.49
  ///
  /// final emptyInts = <int>[];
  /// final emptyTotal = emptyInts.sum(); // 0
  /// ```
  T sum({T? zero}) {
    final iterator = this.iterator;
    if (!iterator.moveNext()) {
      if (zero != null) return zero;
      if (T == int) return 0 as T;
      if (T == double) return 0.0 as T;
      if (T == num) return 0 as T;
      throw StateError(
        "Empty iterable can't be summed without a valid zero fallback.",
      );
    }
    dynamic result = iterator.current;
    while (iterator.moveNext()) {
      result += iterator.current;
    }
    return result;
  }

  /// Maps each element using [mapper] and sums the resulting values in a single
  /// pass using dynamic dispatch of the `+` operator.
  ///
  /// If the iterable is empty, returns [zero] when provided, or automatically
  /// returns `0` / `0.0` when [R] is [int], [double], or [num].
  ///
  /// Throws a [StateError] if the iterable is empty and no fallback value can
  /// be determined.
  ///
  /// Example:
  /// ```dart
  /// final prices = [('apple', 10), ('banana', 25)];
  /// final totalCost = prices.sumBy((item) => item.$2); // 35
  /// ```
  R sumBy<R>(R Function(T) mapper, {R? zero}) {
    final iterator = this.iterator;
    if (!iterator.moveNext()) {
      if (zero != null) return zero;
      if (R == int) return 0 as R;
      if (R == double) return 0.0 as R;
      if (R == num) return 0 as R;
      throw StateError(
        "Empty iterable can't be summed without a valid zero fallback.",
      );
    }
    dynamic result = mapper(iterator.current);
    while (iterator.moveNext()) {
      result += mapper(iterator.current);
    }
    return result;
  }
}
