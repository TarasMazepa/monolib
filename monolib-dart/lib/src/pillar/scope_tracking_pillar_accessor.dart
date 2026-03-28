import 'pillar.dart';
import 'pillar_accessor.dart';
import 'pillar_entry.dart';
import 'pillar_key.dart';
import 'pillar_scope.dart';

class ScopeTrackingPillarAccessor implements PillarAccessor {
  final PillarEntry Function<T>({PillarKey? key, String? token}) entryGetter;
  PillarScope? trackedDependenciesScope;

  ScopeTrackingPillarAccessor(this.entryGetter);

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

  void validateEntry(PillarEntry requestedEntry) {}

  ({T value, PillarScope? scope}) wrapFactory<T>(PillarFactory<T> factory) {
    return (value: factory(this), scope: trackedDependenciesScope);
  }
}
