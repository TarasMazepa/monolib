import 'package:monolib_dart/src/pillar/pillar_entry.dart';
import 'package:monolib_dart/src/pillar/pillar_scope.dart';
import 'package:monolib_dart/src/pillar/scope_tracking_pillar_accessor.dart';

/// A [ScopeTrackingPillarAccessor] that validates [PillarScope] boundaries
/// when resolving dependencies.
///
/// [ScopeEnforcingPillarAccessor] compares the declared
/// [PillarEntry.instanceScope] of [requestingEntry] against the
/// [PillarEntry.effectiveScopeIncludingDependencies] of each requested
/// dependency, preventing longer-lived scoped entries from depending on
/// shorter-lived ones.
///
/// Example:
/// ```dart
/// final accessor = ScopeEnforcingPillarAccessor(
///   requestingEntry,
///   <T>({key, token}) => container.getEntry<T>(key: key, token: token),
/// );
/// final dep = accessor.get<MyDependency>();
/// ```
class ScopeEnforcingPillarAccessor extends ScopeTrackingPillarAccessor {
  /// The dependency entry currently being instantiated.
  ///
  /// Any dependency resolved through this accessor must reside in an equal or
  /// ancestor [PillarScope] relative to this entry's
  /// [PillarEntry.instanceScope].
  final PillarEntry requestingEntry;

  /// Creates a [ScopeEnforcingPillarAccessor] for [requestingEntry] using
  /// [entryGetter] to look up dependencies.
  ScopeEnforcingPillarAccessor(this.requestingEntry, super.entryGetter);

  /// Validates that [requestedEntry] can be consumed by [requestingEntry].
  ///
  /// Ensures that the [PillarEntry.instanceScope] of [requestingEntry] is the
  /// same as or a child of the
  /// [PillarEntry.effectiveScopeIncludingDependencies] of [requestedEntry]. If
  /// [requestedEntry] has no effective scope, validation succeeds immediately;
  /// otherwise, throws an [Exception] when the scope hierarchy is violated.
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
