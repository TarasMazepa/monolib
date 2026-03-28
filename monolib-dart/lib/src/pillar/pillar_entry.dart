import 'pillar.dart';
import 'pillar_key.dart';
import 'pillar_scope.dart';

class PillarEntry {
  final PillarKey key;
  Object? value;
  final PillarFactoryWithScopeTracking factory;
  final PillarScope? instanceScope;
  final bool isInstance;
  PillarScope? effectiveScopeIncludingDependencies;

  PillarEntry({
    required this.key,
    required this.factory,
    this.value,
    this.instanceScope,
  })  : isInstance = value != null,
        effectiveScopeIncludingDependencies = instanceScope;

  T _create<T>() {
    final (:value, :scope) = factory();
    effectiveScopeIncludingDependencies = PillarScope.chooseLowest(
      left: scope,
      right: effectiveScopeIncludingDependencies,
    );
    return value as T;
  }

  T get<T>() {
    return switch (instanceScope) {
      null => _create(),
      _ => (value ??= _create()) as T,
    };
  }
}
