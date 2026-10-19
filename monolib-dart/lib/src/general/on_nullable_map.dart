/// Extension on nullable [Map]s.
extension OnNullableMap<K, V> on Map<K, V>? {
  /// Returns `true` if this map is `null` or empty.
  bool get isNullOrEmpty => this?.isEmpty ?? true;

  /// Returns `true` if this map is not `null` and not empty.
  bool get isNotNullNorEmpty => this?.isNotEmpty ?? false;
}
