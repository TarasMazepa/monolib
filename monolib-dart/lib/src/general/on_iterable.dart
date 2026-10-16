import 'package:monolib_dart/src/general/on_empty_iterable.dart';

/// Provides architectural utilities and extensions for [Iterable]s, focusing on
/// safe and performant traversal, aggregation, and lifecycle hooks.
///
/// This extension augments standard Dart iterables by introducing methods that
/// bypass the limitations of single-pass streams and avoid unnecessary memory
/// allocations. It includes lazily evaluated callbacks ([onEmpty]) that do not
/// force immediate iteration, and dynamic numeric aggregations ([sum], [sumBy])
/// that fold elements directly without requiring intermediate variables or loops.
extension OnIterable<T> on Iterable<T> {
  /// Wraps this iterable in a lazily evaluated [OnEmptyIterable] that triggers
  /// the [onEmpty] callback only if the sequence yields no elements upon iteration.
  ///
  /// Architecturally, this avoids the performance penalty and state exhaustion
  /// associated with preemptively calling [Iterable.isEmpty] on lazily computed
  /// sequences or single-subscription streams converted to iterables. It allows
  /// consumers to chain fallback logic or side effects (like logging warnings or
  /// rendering 'no data' UI placeholders) in a single unified pass.
  ///
  /// ```dart
  /// final metrics = processStats().onEmpty(() {
  ///   logger.warn('No metrics collected during the polling interval.');
  /// });
  ///
  /// for (final stat in metrics) { ... }
  /// ```
  Iterable<T> onEmpty(void Function() onEmpty) {
    return OnEmptyIterable(this, onEmpty);
  }

  /// Aggregates all elements within the iterable via dynamic dispatch of the `+`
  /// operator, returning the total combined result.
  ///
  /// Architecturally, this method relies on runtime dynamic typing to invoke the
  /// underlying type's `+` operator. It eliminates the boilerplate of manually
  /// writing `fold` operations for common numeric types (like `int` and `double`),
  /// while also seamlessly supporting any custom domain objects that implement `+`.
  ///
  /// Note: This method enforces that the sequence must contain at least one element;
  /// an empty iterable has no semantic "zero" concept dynamically, so it cannot
  /// return a default value safely.
  ///
  /// Throws a [StateError] if the iterable is completely empty.
  ///
  /// ```dart
  /// final expenses = <double>[15.50, 42.0, 9.99];
  /// final total = expenses.sum(); // 67.49
  /// ```
  T sum() {
    final iterator = this.iterator;
    if (!iterator.moveNext()) {
      throw StateError("Empty iterable can't be summed");
    }
    dynamic result = iterator.current;
    while (iterator.moveNext()) {
      result += iterator.current;
    }
    return result;
  }

  /// Evaluates each element through the provided [mapper] function and aggregates
  /// the resulting values using dynamic dispatch of the `+` operator.
  ///
  /// Architecturally, this method fuses structural mapping and arithmetic folding
  /// into a single pass. This prevents the event-loop overhead and memory
  /// allocations required to spin up intermediate iterables via `.map(mapper).sum()`.
  /// It is highly efficient for extracting and summing properties from complex
  /// domain objects within tight loops or high-throughput pipelines.
  ///
  /// The [mapper] should return a type `R` that implements the `+` operator
  /// (such as `num`, `int`, `double`, or a compatible custom class).
  ///
  /// Throws a [StateError] if the iterable is completely empty.
  ///
  /// ```dart
  /// final shoppingCart = [Item(price: 10), Item(price: 25)];
  /// final totalCost = shoppingCart.sumBy((item) => item.price); // 35
  /// ```
  R sumBy<R>(R Function(T) mapper) {
    final iterator = this.iterator;
    if (!iterator.moveNext()) {
      throw StateError("Empty iterable can't be summed");
    }
    dynamic result = mapper(iterator.current);
    while (iterator.moveNext()) {
      result += mapper(iterator.current);
    }
    return result;
  }
}
