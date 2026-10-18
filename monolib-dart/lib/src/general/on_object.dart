/// Extension on any object [T] that provides Kotlin-style scoping and casting
/// methods.
///
/// Enables fluent method chaining, inline transformations, and side-effect
/// execution without introducing intermediate local variables.
extension OnObject<T> on T {
  /// Invokes [call] with `this` as its argument and returns `this`.
  ///
  /// Useful for performing side effects (such as logging or configuring an
  /// object) in a call chain without changing the chain's return value.
  ///
  /// Example:
  /// ```dart
  /// final list = <int>[].also((l) => l.add(1));
  /// ```
  T also(void Function(T x) call) {
    call(this);
    return this;
  }

  /// Transforms `this` into a value of type [R] by passing it to [call].
  ///
  /// Useful for inline transformations or scoping an intermediate value to a
  /// single expression.
  ///
  /// Example:
  /// ```dart
  /// final result = '123'.let((str) => int.parse(str));
  /// ```
  R let<R>(R Function(T x) call) => call(this);

  /// Transforms `this` using [call] if [call] is non-null, or returns `this`
  /// unchanged otherwise.
  ///
  /// Example:
  /// ```dart
  /// final value = 10.maybeLet(shouldDouble ? (x) => x * 2 : null);
  /// ```
  T maybeLet(T Function(T x)? call) {
    if (call == null) return this;
    return call(this);
  }

  /// Casts `this` to [R].
  ///
  /// Provides a fluent alternative to the `as` operator at the end of a call
  /// chain without wrapping the expression in parentheses.
  ///
  /// Example:
  /// ```dart
  /// final number = (42 as Object).castTo<int>();
  /// ```
  R castTo<R>() => this as R;
}
