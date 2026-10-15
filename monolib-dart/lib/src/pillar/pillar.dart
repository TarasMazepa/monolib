import 'package:monolib_dart/monolib_dart.dart';
import 'package:monolib_dart/src/pillar/pillar_accessor.dart';
import 'package:monolib_dart/src/pillar/pillar_change_notifier_internal.dart';
import 'package:monolib_dart/src/pillar/pillar_entry.dart';
import 'package:monolib_dart/src/pillar/pillar_key.dart';
import 'package:monolib_dart/src/pillar/pillar_listenable.dart';
import 'package:monolib_dart/src/pillar/pillar_scope.dart';
import 'package:monolib_dart/src/pillar/scope_enforcing_pillar_accessor.dart';
import 'package:monolib_dart/src/pillar/scope_tracking_pillar_accessor.dart';

/// A factory function that constructs an instance of [T] using a [PillarAccessor].
///
/// The [PillarAccessor] provides a scoped window into the dependency injection
/// container, allowing the factory to resolve its own dependencies safely while
/// the container tracks their underlying scopes.
typedef PillarFactory<T> = T Function(PillarAccessor);

/// A pure factory function that constructs an instance of [T] without needing
/// any external dependencies from the container.
///
/// Because it requires no dependencies, its scope is inherently independent
/// of other registered instances.
typedef PillarPureFactory<T> = T Function();

/// An internal factory type used to pair an instantiated [value] with the lowest
/// [PillarScope] encountered while resolving its dependencies.
typedef PillarFactoryWithScopeTracking<T> = ({T value, PillarScope? scope})
    Function();

/// The central Dependency Injection (DI) and Inversion of Control (IoC) container.
///
/// [Pillar] manages the registration, resolution, lifecycle, and scope validation
/// of shared resources within an application. It ensures that dependencies are
/// resolved dynamically when requested and actively prevents architectural scope
/// violations (e.g., stopping a global singleton from implicitly holding a reference
/// to a short-lived request-scoped object).
///
/// Example Usage:
/// ```dart
/// final pillar = Pillar();
/// final sessionScope = PillarScope(name: 'session', parent: const PillarScope.global());
///
/// pillar.register<Database>(pureFactory: () => Database());
/// pillar.register<SessionService>(
///   factory: (accessor) => SessionService(accessor.get<Database>()),
///   scope: sessionScope,
/// );
///
/// final service = pillar.get<SessionService>();
/// ```
class Pillar implements PillarAccessor {
  final Map<PillarKey, PillarEntry> _map = {};
  final Map<PillarScope, PillarChangeNotifierInternal> _scopeChanges = {};

  static ({T value, PillarScope? scope}) _replacedFactory<T>() {
    throw Exception(
      'Instance should have been used instead of calling factory method',
    );
  }

  /// Normalizes the provided [key] and [token] to generate a unique, deterministic
  /// [PillarKey] for container map lookups. Throws if both a [key] and [token] are provided.
  PillarKey _createKey<T>(PillarKey? key, String? token) {
    return switch ((key, token)) {
      (final key?, null) => key,
      (null, final token) => PillarKey.withToken(T, token: token),
      _ => throw Exception(
          'You need to provide key or token or none, but not both',
        ),
    };
  }

  /// Retrieves the internal [PillarEntry] for the given [T], [key], or [token].
  ///
  /// Throws an [Exception] if the requested dependency has not been registered.
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
  /// The resolution lazily evaluates factories if the instance has not yet been
  /// created. To differentiate multiple implementations of the same type [T],
  /// you may provide a unique [token] or an explicit [PillarKey].
  ///
  /// Throws an [Exception] if the requested type (or token) is not registered.
  @override
  T get<T>({PillarKey? key, String? token}) {
    return _get<T>(key: key, token: token).get();
  }

  /// Registers a dependency into the IoC container.
  ///
  /// Dependencies can be registered in three distinct ways:
  /// 1. **[pureFactory]**: Use when the dependency relies on no other services.
  /// 2. **[factory]**: Use when the dependency needs to resolve its own dependencies
  ///    via a provided [PillarAccessor]. The container will automatically track
  ///    and enforce the boundaries of the accessed dependencies.
  /// 3. **[instance]**: Use to register a pre-instantiated, ready-to-use object.
  ///    When providing a raw instance, you MUST explicitly provide an associated [scope].
  ///
  /// A dependency is uniquely identified by its type [T], or optionally a specific
  /// [token] or [key].
  ///
  /// When registering a [factory], the container uses [ScopeTrackingPillarAccessor]
  /// to dynamically track and enforce scope relationships. If an explicit [scope] is
  /// provided with a [factory], [ScopeEnforcingPillarAccessor] guarantees the
  /// factory does not access dependencies narrower than the provided scope.
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

  /// Replaces an existing dependency of type [T] with a new, concrete [instance]
  /// bound to the specified [scope].
  ///
  /// This is commonly used in testing to swap out real implementations for mocks,
  /// or when dynamic state needs to be structurally reset within a session.
  /// Replacing a dependency automatically discards any existing instances tied
  /// to the same or child scopes, and triggers a notification via [changeNotifierFor].
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

  /// Ejects all instantiated dependencies that are strictly bound to the provided
  /// [scope] or any of its child scopes.
  ///
  /// The container iterates over all cached instances. If a registered instance
  /// was created within this [scope] (or within a tracked dependency tree that
  /// touches this [scope]), its cached value is nullified. This effectively forces
  /// the factory to recreate fresh instances the next time they are requested,
  /// acting as a powerful scope-based memory cleanup and state reset mechanism.
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

  /// Returns a [PillarListenable] that broadcasts structural changes to the
  /// container targeting the specified [scope].
  ///
  /// For instance, when [replace] is invoked for a given scope, all registered
  /// listeners on this scope's notifier are synchronously triggered, allowing
  /// the UI or dependent services to react to the container's structural evolution.
  PillarListenable changeNotifierFor(PillarScope scope) {
    return _scopeChanges.putIfAbsent(scope, PillarChangeNotifierInternal.new);
  }
}
