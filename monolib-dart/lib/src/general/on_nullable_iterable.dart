/// Extension on nullable [Iterable]s.
extension OnNullableIterable<T> on Iterable<T>? {
  /// Returns `true` if this iterable is `null` or empty.
  bool get isNullOrEmpty => this?.isEmpty ?? true;

  /// Returns `true` if this iterable is not `null` and not empty.
  bool get isNotNullNorEmpty => this?.isNotEmpty ?? false;
}
