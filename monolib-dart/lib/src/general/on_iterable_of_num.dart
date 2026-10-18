/// Extension on [Iterable] of [num] that provides element-wise division.
extension OnIterableOfNum on Iterable<num> {
  /// Lazily divides each element in this iterable by [divisor].
  ///
  /// Returns a new [Iterable] of [double] values. If [divisor] is `0`, standard
  /// IEEE 754 floating-point rules apply ([double.infinity],
  /// [double.negativeInfinity], or [double.nan]).
  ///
  /// Example:
  /// ```dart
  /// final numbers = [10, 20.0, 5];
  /// final divided = (numbers / 2).toList(); // [5.0, 10.0, 2.5]
  /// ```
  Iterable<double> operator /(num divisor) => map((item) => item / divisor);
}
