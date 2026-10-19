import 'package:monolib_dart/src/pillar/pillar_key.dart';
import 'package:monolib_dart/src/pillar/pillar_scope.dart';

/// Internal factory signature that constructs a dependency and returns the
/// lowest [PillarScope] encountered during its resolution.
typedef PillarFactoryWithScopeTracking<T> = ({T value, PillarScope? scope})
    Function();

/// Determines the more restrictive (lower-level/child) scope between [left] and [right].
PillarScope? chooseLowestScope({PillarScope? left, PillarScope? right}) {
  if (left == null) return right;
  if (right == null) return left;
  if (left.isOrChildOf(right)) return left;
  if (right.isOrChildOf(left)) return right;
  throw Exception("Two disconnected scopes can't be combined: $left, $right");
}

/// Internal container representing a registered dependency within `Pillar`.
class PillarEntry {
  /// The unique key for this dependency.
  final PillarKey key;

  /// The cached instance of the dependency, if instantiated and retained.
  Object? value;

  final PillarFactoryWithScopeTracking _factory;

  /// The declared lifecycle boundary for this dependency, or `null` for transients.
  final PillarScope? instanceScope;

  /// Whether this entry was registered with an existing instance rather than a factory.
  final bool isInstance;

  /// The lowest scope between this entry's scope and its transitive dependencies.
  PillarScope? effectiveScopeIncludingDependencies;

  /// Creates a [PillarEntry].
  PillarEntry({
    required this.key,
    required PillarFactoryWithScopeTracking factory,
    this.value,
    this.instanceScope,
  })  : _factory = factory,
        isInstance = value != null,
        effectiveScopeIncludingDependencies = instanceScope;

  T _create<T>() {
    final (:value, :scope) = _factory();
    effectiveScopeIncludingDependencies = chooseLowestScope(
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
