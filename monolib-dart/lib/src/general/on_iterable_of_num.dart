/// Extension on [Iterable] of [num] providing mathematical operations.
///
/// This extension provides additional methods that can be applied directly to
/// any collection of numbers, such as Lists or Sets containing [int] or [double].
extension OnIterableOfNum on Iterable<num> {
  /// Divides each element in the iterable by the given [divisor].
  ///
  /// Returns a new [Iterable] containing the results as [double] values.
  /// This operation evaluates lazily, meaning the division is only
  /// performed when the resulting iterable is iterated.
  ///
  /// Note: if [divisor] is zero, dividing a non-zero number by zero will result in
  /// [double.infinity] or [double.negativeInfinity], and dividing zero by zero
  /// will result in [double.nan], according to standard Dart floating-point rules.
  ///
  /// Example:
  /// ```dart
  /// final numbers = [10, 20.0, 5];
  /// final divided = (numbers / 2).toList(); // [5.0, 10.0, 2.5]
  /// ```
  Iterable<double> operator /(num divisor) => map((item) => item / divisor);
}
