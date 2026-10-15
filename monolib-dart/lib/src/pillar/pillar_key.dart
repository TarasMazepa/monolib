/// A deterministic, immutable lookup key used by the [Pillar] container to store
/// and resolve dependencies.
///
/// Under the hood, this is a zero-cost extension type wrapping a record of the
/// core Dart [Type] and an optional string [token]. This allows the container
/// to safely distinguish between multiple implementations of the identical abstract
/// interface.
extension type const PillarKey._(({Type type, String? token}) _data) {
  const PillarKey(Type type) : this._((type: type, token: null));

  const PillarKey.withToken(Type type, {required String? token})
      : this._((type: type, token: token));

  static PillarKey of<T>() => PillarKey(T);

  Type get type => _data.type;

  String? get token => _data.token;
}
