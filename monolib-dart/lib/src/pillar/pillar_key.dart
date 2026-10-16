library;

/// A zero-cost identifier used by the [Pillar] dependency injection container
/// to uniquely track and resolve registered dependencies.
///
/// A [PillarKey] acts as a composite dictionary key, pairing a specific Dart
/// [Type] with an optional string identifier ([token]). This design enables
/// consumers to register and inject multiple distinct instances of the same base
/// type by differentiating them with unique tokens, resolving the limitation of
/// type-only injection systems.
///
/// These keys are heavily utilized by [Pillar] and [PillarAccessor] during
/// dependency registration and resolution lifecycles.
///
/// ```dart
/// // Internal registration using a type-only key
/// pillar.register<Database>(key: PillarKey(Database), ...);
///
/// // Internal registration using a tokenized key
/// pillar.register<Database>(key: PillarKey.withToken(Database, token: 'cache'), ...);
/// ```
extension type const PillarKey._(({Type type, String? token}) _data) {
  /// Creates a default [PillarKey] based solely on the provided [type].
  ///
  /// This is the standard key format used when dependencies are registered
  /// without a specific qualifying name, meaning [token] will be `null`.
  const PillarKey(Type type) : this._((type: type, token: null));

  /// Creates a qualified [PillarKey] combining a [type] and an optional [token].
  ///
  /// The [token] parameter allows multiple instances of the same underlying
  /// [type] to exist concurrently within the [Pillar] container. If [token] is
  /// `null`, the resulting key behaves identically to one created by the default
  /// [PillarKey] constructor.
  const PillarKey.withToken(Type type, {required String? token})
      : this._((type: type, token: token));

  /// Generates a default [PillarKey] for the type argument [T].
  ///
  /// This factory provides a clean, type-safe mechanism for generating a key
  /// directly from a generic type parameter without needing to manually pass a
  /// `Type` object.
  static PillarKey of<T>() => PillarKey(T);

  /// The underlying Dart [Type] represented by this key.
  Type get type => _data.type;

  /// The optional string identifier used to differentiate instances of [type],
  /// or `null` if this is a default, untokenized key.
  String? get token => _data.token;
}
