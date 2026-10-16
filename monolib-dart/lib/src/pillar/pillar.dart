/// The core dependency injection container and lifecycle manager for the Pillar framework.
///
/// This library provides the main [Pillar] class, which acts as the central registry
/// for dependencies. It manages the mapping between [PillarKey]s and [PillarEntry]s,
/// enforcing hierarchical lifecycle boundaries via [PillarScope]. By bridging
/// dependency resolution through the [PillarAccessor] interface, it securely
/// tracks scopes during instantiation and handles lifecycle invalidations (e.g.,
/// [Pillar.discard] or [Pillar.replace]) without leaking instances across scopes.
library;

import 'package:monolib_dart/monolib_dart.dart';
import 'package:monolib_dart/src/pillar/pillar_accessor.dart';
import 'package:monolib_dart/src/pillar/pillar_change_notifier_internal.dart';
import 'package:monolib_dart/src/pillar/pillar_entry.dart';
import 'package:monolib_dart/src/pillar/pillar_key.dart';
import 'package:monolib_dart/src/pillar/pillar_listenable.dart';
import 'package:monolib_dart/src/pillar/pillar_scope.dart';
import 'package:monolib_dart/src/pillar/scope_enforcing_pillar_accessor.dart';
import 'package:monolib_dart/src/pillar/scope_tracking_pillar_accessor.dart';

/// A factory function signature for resolving a dependency using a [PillarAccessor].
///
/// Functions of this type are typically registered with [Pillar.register] to
/// provide lazy instantiation of objects that require their own dependencies
/// to be injected from the container.
typedef PillarFactory<T> = T Function(PillarAccessor);

/// A factory function signature for instantiating a dependency without requiring
/// access to the DI container.
///
/// This is used for simple objects that have no downstream dependencies and
/// can be created pure, independent of a [PillarAccessor].
typedef PillarPureFactory<T> = T Function();

/// An internal factory type used to construct dependencies while dynamically
/// tracking the lowest [PillarScope] encountered during their resolution.
///
/// This ensures that instances caching their state do not outlive the shortest
/// lifecycle boundary of any of their nested dependencies.
typedef PillarFactoryWithScopeTracking<T> =
    ({T value, PillarScope? scope}) Function();

/// The primary dependency injection container and lifecycle manager.
///
/// [Pillar] is responsible for registering, caching, and retrieving dependencies.
/// It implements [PillarAccessor] to expose a read-only resolution API, but
/// internally, it maintains the mutable registry of [PillarEntry] objects.
///
/// Architecturally, [Pillar] heavily leverages [PillarScope] to enforce strict
/// hierarchical boundaries. It tracks the lowest scope of dependencies accessed
/// during instantiation (via [ScopeTrackingPillarAccessor]) and enforces those
/// boundaries (via [ScopeEnforcingPillarAccessor]), preventing architectural flaws
/// like a global singleton holding onto a short-lived user session object.
///
/// Example:
/// ```dart
/// final pillar = Pillar();
/// final globalScope = PillarScope.global();
///
/// // Register a singleton scoped globally
/// pillar.register<HttpClient>(
///   factory: (accessor) => HttpClient(),
///   scope: globalScope,
/// );
///
/// // Register a factory that injects the client
/// pillar.register<ApiService>(
///   factory: (accessor) => ApiService(accessor.get<HttpClient>()),
/// );
///
/// // Resolve dependencies
/// final service = pillar.get<ApiService>();
/// ```
class Pillar implements PillarAccessor {
  /// The internal registry mapping fully qualified [PillarKey]s to their
  /// corresponding [PillarEntry], which manages instantiation and caching.
  final Map<PillarKey, PillarEntry> _map = {};

  /// A registry tracking [PillarChangeNotifierInternal]s assigned to specific
  /// lifecycle scopes, allowing for targeted state invalidation broadcasting.
  final Map<PillarScope, PillarChangeNotifierInternal> _scopeChanges = {};

  /// A dummy factory used internally to replace entries via [replace].
  ///
  /// Since [replace] directly injects a concrete `instance`, the factory is
  /// bypassed. If this is invoked accidentally, it indicates a structural flaw.
  static ({T value, PillarScope? scope}) _replacedFactory<T>() {
    throw Exception(
      'Instance should have been used instead of calling factory method',
    );
  }

  /// Synthesizes a [PillarKey] for the generic type [T], falling back to a
  /// provided explicit [key] or string [token] if necessary.
  ///
  /// Throws an [Exception] if both a [key] and a [token] are provided.
  PillarKey _createKey<T>(PillarKey? key, String? token) {
    return switch ((key, token)) {
      (final key?, null) => key,
      (null, final token) => PillarKey.withToken(T, token: token),
      _ => throw Exception(
        'You need to provide key or token or none, but not both',
      ),
    };
  }

  /// Looks up the [PillarEntry] associated with the provided [key] or [token]
  /// for the type [T].
  ///
  /// Throws an [Exception] if no dependency has been registered for that key.
  PillarEntry _get<T>({PillarKey? key, String? token}) {
    final PillarKey effectiveKey = _createKey<T>(key, token);
    return _map[effectiveKey].assertNotNull(
      () => Exception(
        "Pillar doesn't have registration with $effectiveKey, please provide one",
      ),
    );
  }

  /// Resolves and returns an instance of type [T] from the container.
  ///
  /// This retrieves the active instance from the underlying [PillarEntry] or
  /// instantiates a new one via its registered factory. Optional [key] or
  /// [token] parameters can be supplied to disambiguate dependencies of the
  /// same type.
  @override
  T get<T>({PillarKey? key, String? token}) {
    return _get<T>(key: key, token: token).get();
  }

  /// Registers a dependency into the Pillar framework.
  ///
  /// You must provide exactly one of [factory], [pureFactory], or [instance].
  ///
  /// - If [factory] is provided, the dependency can request other dependencies.
  ///   If a [scope] is also given, it acts as a cached singleton bounded by that
  ///   scope. If no scope is given, it acts as a transient factory.
  /// - If [pureFactory] is provided, it instantiates objects without needing
  ///   to access the container.
  /// - If [instance] is provided directly, it bypasses factory instantiation.
  ///   A specific [scope] MUST be provided when injecting a raw instance.
  ///
  /// Optional [key] or [token] parameters can be used to label dependencies
  /// and avoid registration collisions for the same type [T].
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
        (PillarFactory factory, null, null, PillarScope _) =>
          () => ScopeEnforcingPillarAccessor(
            _map[effectiveKey]!,
            _get,
          ).wrapFactory(factory),
        (PillarFactory factory, null, null, null) =>
          () => ScopeTrackingPillarAccessor(_get).wrapFactory(factory),
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

  /// Directly substitutes an existing dependency with a specific [instance]
  /// bound to the given [scope].
  ///
  /// This operation immediately purges any previously cached instances within
  /// the hierarchy that depend on the specified [scope] (by calling [discard]).
  /// It is typically used to hot-swap contexts, such as resetting session-level
  /// dependencies when a user logs in.
  ///
  /// Calling this method also triggers a broadcast on the [PillarListenable]
  /// returned by [changeNotifierFor] for that specific [scope].
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

  /// Invalidates and clears cached instances associated with the given [scope].
  ///
  /// This safely evicts explicit instances and clears the cached state of any
  /// factories whose lowest tracked dependency scope resides within [scope]
  /// or its descendants.
  ///
  /// This enforces lifecycle boundaries, ensuring that components (like session
  /// data) are destroyed without needing to manually map and discard them.
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

  /// Returns a [PillarListenable] tied to the specific [scope].
  ///
  /// This provides an architectural bridge for reactive UI components (e.g.,
  /// via `PillarListenableAdapter` in Flutter) to redraw themselves whenever
  /// [replace] is invoked on the targeted [scope].
  PillarListenable changeNotifierFor(PillarScope scope) {
    return _scopeChanges.putIfAbsent(scope, PillarChangeNotifierInternal.new);
  }
}
