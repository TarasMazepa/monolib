/// A highly strict dependency accessor that enforces architectural lifecycle rules at runtime.
///
/// This file provides [ScopeEnforcingPillarAccessor], an extension of
/// [ScopeTrackingPillarAccessor] that prevents structural scope violations during
/// dynamic factory resolution within the Pillar DI framework.
library;

import 'package:monolib_dart/src/pillar/pillar_entry.dart';
import 'package:monolib_dart/src/pillar/pillar_scope.dart';
import 'package:monolib_dart/src/pillar/scope_tracking_pillar_accessor.dart';

/// A secure, read-only window into the Pillar container that enforces lifecycle boundaries.
///
/// [ScopeEnforcingPillarAccessor] acts at runtime to strictly validate scope hierarchies
/// during dynamic factory resolution. By comparing the explicitly declared scope
/// of the [requestingEntry] against the dynamically computed scope of any dependencies
/// it attempts to resolve, this accessor prevents longer-lived objects (e.g., a global
/// singleton) from accidentally retaining shorter-lived objects (e.g., an active session
/// or user-specific data).
///
/// This is a critical component in Pillar's architecture, guaranteeing that memory leaks
/// and invalid state retention are caught eagerly when dependencies are instantiated,
/// rather than silently failing later in the application lifecycle.
///
/// ```dart
/// // Example of internal usage within the Pillar framework:
/// final accessor = ScopeEnforcingPillarAccessor(
///   requestingEntry,
///   (key, token) => container.getEntry(key, token),
/// );
/// // Resolving a dependency through this accessor will automatically call
/// // validateEntry() to ensure 'requestingEntry' is allowed to hold the result.
/// final dep = accessor.get<MyDependency>();
/// ```
class ScopeEnforcingPillarAccessor extends ScopeTrackingPillarAccessor {
  /// The specific dependency registration that is currently being instantiated.
  ///
  /// This entry's explicit [PillarEntry.instanceScope] acts as the baseline boundary.
  /// Any dependencies requested through this accessor must reside in an equal or
  /// broader (parent) scope compared to this baseline to be legally resolved.
  final PillarEntry requestingEntry;

  /// Creates a new [ScopeEnforcingPillarAccessor] bounded to the [requestingEntry].
  ///
  /// The [entryGetter] delegates the actual underlying dependency lookups, while
  /// this accessor wraps the process to enforce the structural integrity of the
  /// [PillarScope] hierarchy.
  ScopeEnforcingPillarAccessor(this.requestingEntry, super.entryGetter);

  /// Validates that [requestedEntry] can be legally consumed by [requestingEntry].
  ///
  /// This check ensures that the [PillarEntry.instanceScope] of the [requestingEntry]
  /// is equal to or a child of the [PillarEntry.effectiveScopeIncludingDependencies]
  /// of the [requestedEntry].
  ///
  /// If [requestedEntry] has no effective scope (e.g., a pure transient factory with
  /// no scoped dependencies), validation passes immediately. Otherwise, if the rules
  /// are violated, an [Exception] is thrown to fail fast, thereby blocking the illegal
  /// dependency injection.
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
