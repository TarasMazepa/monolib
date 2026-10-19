import 'package:monolib_dart/src/pillar/pillar.dart';
import 'package:monolib_dart/src/pillar/pillar_key.dart';
import 'package:monolib_dart/src/pillar/pillar_scope.dart';
import 'package:monolib_dart/src/pillar/scope_enforcing_pillar_accessor.dart';

/// An internal container representing a single registered dependency within the Pillar framework.
///
/// [PillarEntry] encapsulates a dependency's instantiation logic, caches its active instance
/// (if it's a singleton within its scope), and strictly tracks its lifecycle boundaries.
/// By maintaining both the explicitly declared [instanceScope] and the computed
/// [effectiveScopeIncludingDependencies], this class enables [ScopeEnforcingPillarAccessor]
/// to prevent memory leaks and structural violations (e.g., a global object holding
/// onto a short-lived session dependency).
class PillarEntry {
  /// The unique identifier used to look up this dependency within the framework.
  final PillarKey key;

  /// The cached instance of the dependency, if it has been instantiated and is meant to be reused.
  Object? value;

  /// The provider function responsible for instantiating the dependency.
  ///
  /// This factory is wrapped to track the lowest [PillarScope] of all other dependencies
  /// requested during the creation of this instance.
  final PillarFactoryWithScopeTracking factory;

  /// The explicitly declared lifecycle boundary for this dependency.
  ///
  /// If `null`, the dependency is a transient factory (a new instance is created on every [get]).
  /// If provided, the dependency acts as a singleton constrained to this specific [PillarScope].
  final PillarScope? instanceScope;

  /// Indicates whether this entry was initialized with an existing instance rather than a factory.
  ///
  /// When `true`, it implies [value] was provided directly during registration, bypassing
  /// the need to invoke [factory].
  final bool isInstance;

  /// The most restrictive lifecycle boundary associated with this dependency tree.
  ///
  /// Initially set to [instanceScope], this value is dynamically updated during instantiation
  /// to be the lowest scope between its own explicit scope and the scopes of any downstream
  /// dependencies it requests. This ensures the instance does not outlive its shortest-lived
  /// collaborator.
  PillarScope? effectiveScopeIncludingDependencies;

  /// Constructs a [PillarEntry] to manage a dependency's lifecycle and instantiation.
  ///
  /// This constructor initializes the [isInstance] flag based on the presence of [value],
  /// and seeds [effectiveScopeIncludingDependencies] with the explicitly provided [instanceScope].
  PillarEntry({
    required this.key,
    required this.factory,
    this.value,
    this.instanceScope,
  })  : isInstance = value != null,
        effectiveScopeIncludingDependencies = instanceScope;

  /// Invokes the [factory] to create a new instance of [T], tracking nested dependency scopes.
  ///
  /// During execution, the [factory] reports the lowest scope encountered among any
  /// dependencies requested inside it. This lowest scope is then merged into
  /// [effectiveScopeIncludingDependencies] via [PillarScope.chooseLowest].
  T _create<T>() {
    final (:value, :scope) = factory();
    effectiveScopeIncludingDependencies = PillarScope.chooseLowest(
      left: scope,
      right: effectiveScopeIncludingDependencies,
    );
    return value as T;
  }

  /// Retrieves the dependency instance of type [T].
  ///
  /// If [instanceScope] is `null`, this acts as a transient factory, returning a fresh
  /// instance on every call. If [instanceScope] is provided, it lazily
  /// caches and returns the singleton instance tied to that scope.
  T get<T>() {
    return switch (instanceScope) {
      null => _create(),
      _ => (value ??= _create()) as T,
    };
  }
}
