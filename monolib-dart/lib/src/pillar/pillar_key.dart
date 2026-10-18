/// A composite lookup key used by `Pillar` to identify registered dependencies.
///
/// [PillarKey] pairs a Dart [Type] with an optional string [token], allowing
/// multiple registrations of the same type to be disambiguated by name.
///
/// Example:
/// ```dart
/// // Type-only key
/// const defaultKey = PillarKey(Database);
///
/// // Tokenized key
/// const cacheKey = PillarKey.withToken(Database, token: 'cache');
/// ```
extension type const PillarKey._(({Type type, String? token}) _data) {
  /// Creates a [PillarKey] for [type] with no [token].
  const PillarKey(Type type) : this._((type: type, token: null));

  /// Creates a [PillarKey] combining [type] and an optional [token].
  ///
  /// The [token] distinguishes multiple registrations of the same [type]
  /// within a `Pillar` container. If [token] is `null`, the key is equivalent
  /// to `PillarKey(type)`.
  const PillarKey.withToken(Type type, {required String? token})
      : this._((type: type, token: token));

  /// Returns a [PillarKey] for the type argument [T].
  static PillarKey of<T>() => PillarKey(T);

  /// The Dart [Type] represented by this key.
  Type get type => _data.type;

  /// The optional string token differentiating registrations of [type], or
  /// `null` if untokenized.
  String? get token => _data.token;
}
