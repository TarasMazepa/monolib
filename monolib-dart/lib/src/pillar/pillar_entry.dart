import 'package:monolib_dart/src/pillar/pillar.dart';
import 'package:monolib_dart/src/pillar/pillar_key.dart';
import 'package:monolib_dart/src/pillar/pillar_scope.dart';

/// An internal representation of a registered dependency within the [Pillar] container.
///
/// This class holds the metadata required to safely resolve and scope a dependency.
/// It wraps the factory delegate, the explicitly requested scope (if any), the
/// lazily instantiated concrete [value], and dynamically tracks the most restrictive
/// boundary limit ([effectiveScopeIncludingDependencies]) inferred from resolving
/// its dependencies.
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
