import 'package:monolib_dart/src/pillar/pillar_entry.dart';
import 'package:monolib_dart/src/pillar/pillar_scope.dart';
import 'package:monolib_dart/src/pillar/scope_tracking_pillar_accessor.dart';

/// A specialized [PillarAccessor] that rigorously enforces valid scope trees
/// at runtime when executing dynamic factories.
///
/// When a factory wrapped by this accessor requests a dependency from the container,
/// this accessor intercepts the request and verifies the boundary. It ensures that
/// the requested object's lowest calculated [PillarScope] is not more transient
/// (narrower) than the scope of the object currently being manufactured. If a
/// global object attempts to cache a session-scoped dependency, this accessor
/// detects the inversion and throws a fatal architectural exception.
class ScopeEnforcingPillarAccessor extends ScopeTrackingPillarAccessor {
  /// The specific target entry within the [Pillar] container that is currently
  /// having its factory executed.
  final PillarEntry requestingEntry;

  ScopeEnforcingPillarAccessor(this.requestingEntry, super.entryGetter);

  @override

  /// Executes the core scope enforcement logic.
  ///
  /// Compares the calculated boundary limits of the [requestedEntry] against
  /// the required boundary of the [requestingEntry]. Throws an Exception if the
  /// request breaks the dependency tree rules (i.e. if the requesting scope is
  /// not a valid child of the requested scope).
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
