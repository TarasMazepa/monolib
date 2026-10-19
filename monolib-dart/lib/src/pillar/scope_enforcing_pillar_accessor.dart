import 'package:monolib_dart/src/pillar/pillar_entry.dart';
import 'package:monolib_dart/src/pillar/pillar_scope.dart';
import 'package:monolib_dart/src/pillar/scope_tracking_pillar_accessor.dart';

/// Internal [ScopeTrackingPillarAccessor] that validates [PillarScope] boundaries
/// when resolving dependencies.
class ScopeEnforcingPillarAccessor extends ScopeTrackingPillarAccessor {
  final PillarEntry _requestingEntry;

  /// Creates a [ScopeEnforcingPillarAccessor] for [_requestingEntry].
  ScopeEnforcingPillarAccessor(this._requestingEntry, super.entryGetter);

  /// Validates that [requestedEntry] can be consumed by [_requestingEntry].
  @override
  void validateEntry(PillarEntry requestedEntry) {
    final PillarScope? requestedEntryScope =
        requestedEntry.effectiveScopeIncludingDependencies;
    if (requestedEntryScope == null) return;
    final PillarScope requestingEntryScope = _requestingEntry.instanceScope!;
    if (!requestingEntryScope.isOrChildOf(requestedEntryScope)) {
      throw Exception(
        '${_requestingEntry.key} with $requestingEntryScope requesting for ${requestedEntry.key} with $requestedEntryScope, which is not accessible as $requestingEntryScope is not child scope of $requestedEntryScope',
      );
    }
  }
}
