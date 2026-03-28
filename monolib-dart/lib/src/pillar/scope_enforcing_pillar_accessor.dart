import 'pillar_entry.dart';
import 'pillar_scope.dart';
import 'scope_tracking_pillar_accessor.dart';

class ScopeEnforcingPillarAccessor extends ScopeTrackingPillarAccessor {
  final PillarEntry requestingEntry;

  ScopeEnforcingPillarAccessor(this.requestingEntry, super.entryGetter);

  @override
  void validateEntry(PillarEntry requestedEntry) {
    final PillarScope? requestedEntryScope =
        requestedEntry.effectiveScopeIncludingDependencies;
    if (requestedEntryScope == null) return;
    final PillarScope requestingEntryScope = requestingEntry.instanceScope!;
    if (!requestingEntryScope.isOrChildOf(requestedEntryScope)) {
      throw Exception(
        '${requestingEntry.key} with $requestingEntryScope requesting for ${requestedEntry.key} with $requestedEntryScope, which is not accessible as $requestingEntryScope is not child scope of $requestedEntryScope',
      );
    }
  }
}
