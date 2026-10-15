import 'package:monolib_dart/src/pillar/pillar.dart';
import 'package:monolib_dart/src/pillar/pillar_accessor.dart';
import 'package:monolib_dart/src/pillar/pillar_entry.dart';
import 'package:monolib_dart/src/pillar/pillar_key.dart';
import 'package:monolib_dart/src/pillar/pillar_scope.dart';

/// A [PillarAccessor] that tracks the lowest scope of all dependencies it accesses.
///
/// This is typically used to determine the appropriate [PillarScope] for a newly
/// created instance based on the scopes of the dependencies it requested during
/// its creation.
/// A [PillarAccessor] that dynamically resolves dependencies while tracking the
/// narrowest boundaries (lowest scopes) encountered during resolution.
///
/// This accessor is used by the container to wrap factories where an explicit
/// scope is not provided. By tracking every call to [get], the container can
/// automatically infer and bind the new object to the lowest common denominator
/// scope among all its dependencies.
class ScopeTrackingPillarAccessor implements PillarAccessor {
  /// The function used to retrieve a [PillarEntry] for a given type [T], [key], or [token].
  final PillarEntry Function<T>({PillarKey? key, String? token}) entryGetter;

  /// The lowest [PillarScope] encountered among all tracked dependencies so far.
  ///
  /// This value is updated progressively as [get] is called, maintaining the
  /// minimum scope according to [PillarScope.chooseLowest]. It is `null` if
  /// no dependencies have been tracked yet.
  PillarScope? trackedDependenciesScope;

  /// Creates a new [ScopeTrackingPillarAccessor] with the provided [entryGetter].
  ScopeTrackingPillarAccessor(this.entryGetter);

  /// Retrieves an instance of type [T] and tracks its effective scope.
  ///
  /// This method looks up the [PillarEntry] using [entryGetter], retrieves its
  /// value, optionally validates it via [validateEntry], and updates
  /// [trackedDependenciesScope] to be the lowest scope between its current value
  /// and the retrieved entry's effective scope.
  ///
  /// The [key] and [token] parameters can be used to qualify the lookup.
  @override
  T get<T>({PillarKey? key, String? token}) {
    final PillarEntry requestedEntry = entryGetter<T>(key: key, token: token);
    final T result = requestedEntry.get<T>();
    validateEntry(requestedEntry);
    trackedDependenciesScope = PillarScope.chooseLowest(
      left: trackedDependenciesScope,
      right: requestedEntry.effectiveScopeIncludingDependencies,
    );
    return result;
  }

  /// Validates the [requestedEntry] immediately after its value has been retrieved.
  ///
  /// By default, this method does nothing, but it can be overridden by subclasses
  /// to enforce additional constraints on dependencies.
  void validateEntry(PillarEntry requestedEntry) {}

  /// Executes the provided [factory] function using `this` as the accessor, and
  /// returns both the resulting value and the final tracked scope.
  ///
  /// The returned record contains:
  /// - `value`: The instance of [T] created by the [factory].
  /// - `scope`: The lowest [PillarScope] encountered during the factory execution,
  ///   which is the final value of [trackedDependenciesScope].
  ///
  /// ```dart
  /// final accessor = ScopeTrackingPillarAccessor(myEntryGetter);
  /// final result = accessor.wrapFactory((a) => MyClass(a.get<Dependency>()));
  /// print(result.scope); // The lowest scope of accessed dependencies
  /// ```
  ({T value, PillarScope? scope}) wrapFactory<T>(PillarFactory<T> factory) {
    return (value: factory(this), scope: trackedDependenciesScope);
  }
}
