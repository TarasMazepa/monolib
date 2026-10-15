/// Provides architectural utilities to collapse collections of synchronous
/// transformation functions into a single, cohesive executable unit.
///
/// This extension is designed for middleware architectures, data pipelines,
/// or multi-step mappers where an initial state passes sequentially through
/// a series of optional interceptors or transformers of the same type.
extension OnIterableOfNullableFunctions<T> on Iterable<T Function(T)?> {
  /// Compiles multiple potential transformations into a single mathematical
  /// function composition `f(g(h(x)))`.
  ///
  /// This getter evaluates the collection sequentially from back-to-front
  /// (the last mapper in the collection is applied first to the initial value `x`,
  /// passing its output progressively up to the first mapper).
  ///
  /// Any `null` functions present in the iterable are safely discarded via
  /// [nonNulls] without interrupting the pipeline. The optimized switch
  /// internally avoids iteration overhead for small collections (up to 4 functions).
  ///
  /// Returns a composed function `T Function(T)`, or `null` if the entire
  /// collection is empty or exclusively contains `null` items.
  ///
  /// ```dart
  /// final mappers = <int Function(int)?>[
  ///   (x) => x + 1, // Runs last
  ///   null,         // Safely ignored
  ///   (x) => x * 2, // Runs first
  /// ];
  ///
  /// // Mathematically evaluates: (x * 2) + 1
  /// final result = mappers.combined?.call(5); // Returns 11
  /// ```
  T Function(T)? get combined => switch (nonNulls.toList(growable: false)) {
        [] => null,
        [final mapper] => mapper,
        [final mapper1, final mapper2] => (x) => mapper1(mapper2(x)),
        [final mapper1, final mapper2, final mapper3] => (x) => mapper1(
              mapper2(mapper3(x)),
            ),
        [final mapper1, final mapper2, final mapper3, final mapper4] => (x) =>
            mapper1(mapper2(mapper3(mapper4(x)))),
        final mappers => (x) => mappers.reversed.fold(
              x,
              (value, mapper) => mapper(value),
            ),
      };
}
