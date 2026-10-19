import 'package:monolib_dart/src/pillar/pillar.dart';
import 'package:monolib_dart/src/pillar/pillar_accessor.dart';
import 'package:monolib_dart/src/pillar/pillar_entry.dart';
import 'package:monolib_dart/src/pillar/pillar_key.dart';
import 'package:monolib_dart/src/pillar/pillar_scope.dart';

/// Internal [PillarAccessor] that tracks the lowest scope of all dependencies it accesses.
class ScopeTrackingPillarAccessor implements PillarAccessor {
  final PillarEntry Function<T>({PillarKey? key, String? token}) _entryGetter;

  PillarScope? _trackedDependenciesScope;

  /// Creates a [ScopeTrackingPillarAccessor] with the provided [entryGetter].
  ScopeTrackingPillarAccessor(
    PillarEntry Function<T>({PillarKey? key, String? token}) entryGetter,
  ) : _entryGetter = entryGetter;

  /// Retrieves an instance of type [T] and updates the tracked scope.
  @override
  T get<T>({PillarKey? key, String? token}) {
    final PillarEntry requestedEntry = _entryGetter<T>(key: key, token: token);
    final T result = requestedEntry.get<T>();
    validateEntry(requestedEntry);
    _trackedDependenciesScope = chooseLowestScope(
      left: _trackedDependenciesScope,
      right: requestedEntry.effectiveScopeIncludingDependencies,
    );
    return result;
  }

  /// Hook for subclasses to validate [requestedEntry].
  void validateEntry(PillarEntry requestedEntry) {}

  /// Executes [factory] and returns the created value with the tracked scope.
  ({T value, PillarScope? scope}) wrapFactory<T>(PillarFactory<T> factory) {
    return (value: factory(this), scope: _trackedDependenciesScope);
  }
}
