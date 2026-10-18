/// Extension on nullable objects that provides chainable non-null assertions.
///
/// Enables inline null validation within expression pipelines (such as looking
/// up a required entry in `Pillar`) without breaking the call chain for an
/// imperative `if` check.
extension OnNullableObject<T> on T? {
  /// Returns this value as a non-nullable [T], or throws the [Exception]
  /// produced by [exceptionProducer] if this value is `null`.
  ///
  /// Evaluates [exceptionProducer] lazily only when this value is `null`.
  ///
  /// Example:
  /// ```dart
  /// final dependency = registryMap[key].assertNotNull(
  ///   () => Exception("Registry doesn't have a registration for $key"),
  /// );
  /// ```
  T assertNotNull(Exception Function() exceptionProducer) =>
      this ?? (throw exceptionProducer());
}
