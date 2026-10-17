/// Defines the read-only dependency retrieval interface for the Pillar dependency injection framework.
///
/// The `PillarAccessor` provides a secure window into the container, allowing components
/// and factories to resolve dependencies without gaining mutability access (such as registering
/// or overriding dependencies). It acts as the primary abstraction for resolving instances
/// during factory execution, ensuring that implementations like `ScopeEnforcingPillarAccessor`
/// can securely track and validate hierarchical lifecycle scopes at runtime without exposing
/// the underlying container structure.
library;

import 'package:monolib_dart/src/pillar/pillar_key.dart';

/// A read-only interface for retrieving registered dependencies from the Pillar container.
///
/// The [PillarAccessor] is primarily passed into factory functions to resolve nested dependencies.
/// Because it acts as a facade, specific implementations (like `ScopeEnforcingPillarAccessor` or
/// `ScopeTrackingPillarAccessor`) enforce rules such as lifecycle scope validation (preventing a
/// longer-lived scope from retaining dependencies from a shorter-lived `PillarScope`) and scope tracking
/// while returning instances.
abstract class PillarAccessor {
  /// Resolves and returns an instance of type [T] from the dependency injection container.
  ///
  /// This method locates the registered factory or cached instance corresponding to the type [T].
  /// If multiple instances of the same type are registered, a [token] or explicit [key] can be
  /// provided to uniquely identify the dependency.
  ///
  /// If the dependency is not found, or if resolving it violates hierarchical scope boundaries
  /// (when using a scope-enforcing implementation), an exception is thrown.
  ///
  /// - [key]: An optional exact [PillarKey] to locate the dependency. If provided, it overrides [token].
  /// - [token]: An optional string identifier used to differentiate dependencies of the same type [T].
  ///
  /// ```dart
  /// // Resolving a standard singleton or scoped dependency
  /// final config = accessor.get<AppConfig>();
  ///
  /// // Resolving a named dependency using a token
  /// final apiClient = accessor.get<ApiClient>(token: 'authenticated');
  /// ```
  T get<T>({PillarKey? key, String? token});
}

/// Provides utility methods on [PillarAccessor] to streamline common dependency resolution patterns.
///
/// This extension simplifies advanced resolution techniques, such as assisted injection,
/// where a dependency requires both container-managed dependencies and runtime parameters
/// to be instantiated.
extension OnPillarAccessor on PillarAccessor {
  /// Resolves a factory function from the container and immediately invokes it with the provided [parameter].
  ///
  /// This is used for "assisted injection," where an object depends on both registered container
  /// services and a value only available at runtime. The container must have a registered factory
  /// of type `T Function(P)`. This method fetches that function using [get] and immediately executes
  /// it by passing [parameter].
  ///
  /// - [parameter]: The runtime value of type [P] to pass into the resolved factory.
  /// - [key]: An optional [PillarKey] targeting the specific factory registration.
  /// - [token]: An optional string token if the factory is registered with a name.
  ///
  /// ```dart
  /// // In the container setup:
  /// // pillar.registerFactory<ViewModel Function(String)>((accessor) => (userId) => ViewModel(accessor.get<UserRepository>(), userId));
  ///
  /// // At the call site:
  /// final viewModel = accessor.assisted<ViewModel, String>('user_123');
  /// ```
  T assisted<T, P>(P parameter, {PillarKey? key, String? token}) {
    return get<T Function(P)>(key: key, token: token)(parameter);
  }
}
