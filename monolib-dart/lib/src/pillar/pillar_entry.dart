import 'package:monolib_dart/src/pillar/pillar.dart';
import 'package:monolib_dart/src/pillar/pillar_key.dart';
import 'package:monolib_dart/src/pillar/pillar_scope.dart';

/// Internal container representing a registered dependency within [Pillar].
class PillarEntry {
  /// The unique key for this dependency.
  final PillarKey key;

  /// The cached instance of the dependency, if instantiated and retained.
  Object? value;

  /// The factory responsible for instantiating the dependency.
  final PillarFactoryWithScopeTracking factory;

  /// The declared lifecycle boundary for this dependency, or `null` for transients.
  final PillarScope? instanceScope;

  /// Whether this entry was registered with an existing instance rather than a factory.
  final bool isInstance;

  /// The lowest scope between this entry's scope and its transitive dependencies.
  PillarScope? effectiveScopeIncludingDependencies;

  /// Creates a [PillarEntry].
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

  /// Retrieves or instantiates the dependency of type [T].
  T get<T>() {
    return switch (instanceScope) {
      null => _create(),
      _ => (value ??= _create()) as T,
    };
  }
}
