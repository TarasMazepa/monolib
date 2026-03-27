import 'pillar_key.dart';

abstract class PillarAccessor {
  T get<T>({PillarKey? key, String? token});
}

extension PillarAccessorAssisted on PillarAccessor {
  T assisted<T, P>(P parameter, {PillarKey? key, String? token}) {
    return get<T Function(P)>(key: key, token: token)(parameter);
  }
}
