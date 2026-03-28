import '../../monolib_dart.dart';
import 'pillar_accessor.dart';
import 'pillar_change_notifier.dart';
import 'pillar_entry.dart';
import 'pillar_key.dart';
import 'pillar_listenable.dart';
import 'pillar_scope.dart';
import 'scope_enforcing_pillar_accessor.dart';
import 'scope_tracking_pillar_accessor.dart';

typedef PillarFactory<T> = T Function(PillarAccessor);
typedef PillarPureFactory<T> = T Function();
typedef PillarFactoryWithScopeTracking<T> = ({T value, PillarScope? scope})
    Function();

class Pillar implements PillarAccessor {
  final Map<PillarKey, PillarEntry> _map = {};
  final Map<PillarScope, PillarChangeNotifierInternal> _scopeChanges = {};

  static ({T value, PillarScope? scope}) _replacedFactory<T>() {
    throw Exception(
      'Instance should have been used instead of calling factory method',
    );
  }

  PillarKey _createKey<T>(PillarKey? key, String? token) {
    return switch ((key, token)) {
      (final key?, null) => key,
      (null, final token) => PillarKey.withToken(T, token: token),
      _ => throw Exception(
          'You need to provide key or token or none, but not both',
        ),
    };
  }

  PillarEntry _get<T>({PillarKey? key, String? token}) {
    final PillarKey effectiveKey = _createKey<T>(key, token);
    return _map[effectiveKey].assertNotNull(
      () => Exception(
        "Pillar doesn't have registration with $effectiveKey, please provide one",
      ),
    );
  }

  @override
  T get<T>({PillarKey? key, String? token}) {
    return _get<T>(key: key, token: token).get();
  }

  void register<T>({
    PillarKey? key,
    String? token,
    PillarFactory<T>? factory,
    PillarPureFactory<T>? pureFactory,
    T? instance,
    PillarScope? scope,
  }) {
    final PillarKey effectiveKey = _createKey<T>(key, token);
    if (_map.containsKey(effectiveKey)) {
      throw Exception('$effectiveKey already registered');
    }
    _map[effectiveKey] = PillarEntry(
      key: effectiveKey,
      factory: switch ((factory, pureFactory, instance, scope)) {
        (PillarFactory factory, null, null, PillarScope _) => () =>
            ScopeEnforcingPillarAccessor(
              _map[effectiveKey]!,
              _get,
            ).wrapFactory(factory),
        (PillarFactory factory, null, null, null) => () =>
            ScopeTrackingPillarAccessor(_get).wrapFactory(factory),
        (null, PillarPureFactory factory, null, _) => () => (
              value: factory(),
              scope: null,
            ),
        (null, null, T _, PillarScope _) => () {
            throw Exception(
              'Instance should have been used instead of calling factory method',
            );
          },
        (null, null, T _, null) => throw Exception(
            'Instance should have scope specified',
          ),
        _ => throw Exception(
            'You should supply factory, pureFactory, or instance',
          ),
      },
      value: instance,
      instanceScope: scope,
    );
  }

  void replace<T>({required T instance, required PillarScope scope}) {
    discard(scope);
    final PillarKey createdKey = _createKey<T>(null, null);
    _map[createdKey] = PillarEntry(
      key: createdKey,
      factory: _replacedFactory<T>,
      value: instance,
      instanceScope: scope,
    );
    _scopeChanges[scope]?.notify();
  }

  void discard(PillarScope scope) {
    _map.removeWhere(
      (key, value) =>
          value.isInstance && value.instanceScope?.isOrChildOf(scope) == true,
    );
    for (final MapEntry<PillarKey, PillarEntry> entry in _map.entries) {
      if (entry.value.effectiveScopeIncludingDependencies?.isOrChildOf(scope) ==
          true) {
        entry.value.value = null;
      }
    }
  }

  PillarListenable changeNotifierFor(PillarScope scope) {
    return _scopeChanges.putIfAbsent(scope, PillarChangeNotifierInternal.new);
  }
}
