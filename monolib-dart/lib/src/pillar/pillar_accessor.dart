import 'package:monolib_dart/src/pillar/pillar_key.dart';

/// A read-only interface to request mapped dependencies from the IoC container.
///
/// This accessor acts as the secure bridge passed to dependency factories during
/// resolution. It allows the newly-constructed object to securely query for its
/// dependencies via [get] without exposing the mutative configuration methods
/// (like `register` or `replace`) present on the full [Pillar] instance.
abstract class PillarAccessor {
  /// Resolves the requested dependency of type [T].
  ///
  /// Optionally, you may distinguish implementations by supplying a specific
  /// [key] or a string [token]. Throws an exception if the underlying
  /// container cannot resolve the request or if an illegal scope violation occurs.
  T get<T>({PillarKey? key, String? token});
}

/// Convenience extensions to easily inject parameters when resolving nested
/// dynamic factory closures from the [PillarAccessor].
extension OnPillarAccessor on PillarAccessor {
  /// Retrieves an injected factory closure from the container and immediately
  /// invokes it using the provided [parameter].
  ///
  /// This pattern is heavily utilized for 'assisted injection', where an object
  /// needs dependencies from the container but ALSO requires dynamic state explicitly
  /// passed from the immediate call site (e.g., passing a dynamically loaded ID
  /// into a view model factory).
  T assisted<T, P>(P parameter, {PillarKey? key, String? token}) {
    return get<T Function(P)>(key: key, token: token)(parameter);
  }
}
