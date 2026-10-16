/// Utilities that introduce Kotlin-style scoping functions to all Dart objects.
///
/// The [OnObject] extension provides functional programming constructs that
/// allow developers to execute blocks of code within the context of an object,
/// facilitating fluent method chaining, side-effect execution without breaking
/// expression pipelines, and localized variable scoping. This minimizes the
/// need for intermediate local variables and reduces boilerplate when configuring
/// objects or performing inline transformations.
library;

/// Extensions providing functional scoping operations on any object.
extension OnObject<T> on T {
  /// Executes the given [call] closure with this object as its argument, then
  /// returns this original object.
  ///
  /// This is particularly useful for performing side effects (like logging,
  /// triggering callbacks, or mutating properties) during a fluent builder chain
  /// without breaking the chain's return value.
  ///
  /// Example:
  /// ```dart
  /// final sink = StreamController<int>()
  ///   .also((c) => c.add(1))
  ///   .also((c) => print('Initialized controller'));
  /// ```
  T also(void Function(T x) call) {
    call(this);
    return this;
  }

  /// Transforms this object into a new value of type [R] by passing it to the
  /// [call] closure.
  ///
  /// This method is ideal for mapping a value from one type to another inline,
  /// or for scoping an intermediate computation so its variable doesn't leak
  /// into the broader method scope.
  ///
  /// Example:
  /// ```dart
  /// final result = '123'.let((str) => int.parse(str));
  /// ```
  R let<R>(R Function(T x) call) => call(this);

  /// Conditionally transforms this object if [call] is provided, otherwise
  /// returns the original object unchanged.
  ///
  /// This is useful for conditionally applying a transformation or configuration
  /// step in a functional pipeline without writing an external `if` statement.
  ///
  /// Example:
  /// ```dart
  /// final config = defaultConfig
  ///   .maybeLet(shouldOverride ? (c) => applyOverride(c) : null);
  /// ```
  T maybeLet(T Function(T x)? call) {
    if (call == null) return this;
    return call(this);
  }

  /// Casts this object to the generic type [R].
  ///
  /// This provides a functional alternative to the standard `as` operator,
  /// enabling type casting at the end of a fluent call chain without needing
  /// to wrap the entire expression in parentheses.
  ///
  /// Example:
  /// ```dart
  /// final widget = buildWidget().castTo<Container>();
  /// ```
  R castTo<R>() => this as R;
}
