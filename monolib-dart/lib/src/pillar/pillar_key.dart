extension type const PillarKey._(({Type type, String? token}) _data) {
  const PillarKey(Type type) : this._((type: type, token: null));

  const PillarKey.withToken(Type type, {required String? token})
    : this._((type: type, token: token));

  static PillarKey of<T>() => PillarKey(T);

  Type get type => _data.type;
  String? get token => _data.token;
}
