/// A collection of extensions on [Comparable] for declarative comparison chains.
library;

/// An extension on [Comparable] types that facilitates declarative, cascaded
/// sorting logic.
///
/// In Dart, standard sorting using [Comparable.compareTo] requires verbose
/// conditional blocks when sorting by multiple fields (e.g., returning the
/// result if not 0, otherwise falling through to the next comparison). This
/// extension simplifies that pattern by returning `null` instead of `0` on
/// equality. This allows developers to use Dart's null-coalescing operator
/// (`??`) to neatly chain multiple comparisons together.
extension OnComparable<T extends Comparable<dynamic>> on T {
  /// Compares this object to [other], returning `null` if they are equal.
  ///
  /// This method serves as an architectural adapter for [Comparable.compareTo],
  /// converting its standard `0` equality result into a `null`. By yielding
  /// `null` when two items are identical for a given sort criteria, it enables
  /// the execution pipeline to transparently fall back to secondary or tertiary
  /// sorting conditions using the `??` operator.
  ///
  /// ```dart
  /// class Person {
  ///   final String lastName;
  ///   final String firstName;
  ///   final int age;
  ///
  ///   Person(this.lastName, this.firstName, this.age);
  /// }
  ///
  /// final people = <Person>[...];
  ///
  /// // Sort by last name, then first name, then age.
  /// people.sort((a, b) {
  ///   return a.lastName.compareChain(b.lastName) ??
  ///          a.firstName.compareChain(b.firstName) ??
  ///          a.age.compareTo(b.age);
  /// });
  /// ```
  int? compareChain(T other) {
    final result = compareTo(other);
    return result == 0 ? null : result;
  }
}
