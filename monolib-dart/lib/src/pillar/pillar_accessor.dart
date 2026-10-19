import 'package:monolib_dart/src/pillar/pillar_key.dart';

/// A read-only interface for retrieving registered dependencies from a `Pillar`
/// container.
///
/// [PillarAccessor] is passed to factory functions so they can resolve
/// transitive dependencies without exposing container mutation methods.
/// Implementations such as `ScopeTrackingPillarAccessor` and
/// `ScopeEnforcingPillarAccessor` track and validate `PillarScope` hierarchies
/// during resolution.
abstract class PillarAccessor {
  /// Resolves and returns an instance of type [T] from the container.
  ///
  /// If multiple registrations of type [T] exist, provide [key] or [token] to
  /// disambiguate them. Throws an [Exception] if the dependency is not
  /// registered or if resolving it violates `PillarScope` constraints.
  ///
  /// - [key]: An optional [PillarKey] identifying the dependency. Cannot be
  ///   combined with [token].
  /// - [token]: An optional string token differentiating registrations of the
  ///   same type [T].
  ///
  /// Example:
  /// ```dart
  /// // Resolving a standard dependency
  /// final config = accessor.get<AppConfig>();
  ///
  /// // Resolving a named dependency using a token
  /// final apiClient = accessor.get<ApiClient>(token: 'authenticated');
  /// ```
  T get<T>({PillarKey? key, String? token});
}

/// Extension on [PillarAccessor] that supports assisted dependency injection.
extension OnPillarAccessor on PillarAccessor {
  /// Resolves a factory of type `T Function(P)` from the container and invokes
  /// it with [parameter].
  ///
  /// Use this for assisted injection when creating an instance of [T] requires
  /// both container-managed dependencies and a runtime [parameter] of type [P].
  ///
  /// - [parameter]: The runtime argument passed to the resolved factory.
  /// - [key]: An optional [PillarKey] identifying the factory registration.
  /// - [token]: An optional string token if the factory was registered with a
  ///   token.
  ///
  /// Example:
  /// ```dart
  /// // In the container setup:
  /// // pillar.register<ViewModel Function(String)>(
  /// //   factory: (accessor) =>
  /// //       (userId) => ViewModel(accessor.get<UserRepository>(), userId),
  /// // );
  ///
  /// // At the call site:
  /// final viewModel = accessor.assisted<ViewModel, String>('user_123');
  /// ```
  T assisted<T, P>(P parameter, {PillarKey? key, String? token}) {
    return get<T Function(P)>(key: key, token: token)(parameter);
  }
}
