/// A structured, hierarchical identifier used to strictly bound the lifecycles
/// of dependencies inside the [Pillar] container.
///
/// Scopes prevent resource leaks and architectural boundary violations. For example,
/// a `databaseScope` might have a global parent, while a `sessionScope` exists
/// as a child of the `databaseScope`. If an object registered in the global scope
/// attempts to resolve an object bound to the session scope, the [Pillar] container
/// will immediately throw an error via [ScopeEnforcingPillarAccessor], enforcing
/// deterministic dependency trees.
class PillarScope {
  /// The human-readable identifier of this scope, primarily used for debugging
  /// and logging exception messages.
  final String name;

  /// The immediate hierarchical parent of this scope. If `null`, this scope
  /// is considered a root-level scope.
  final PillarScope? parent;

  /// A predefined, root-level global scope conventionally used for application-wide
  /// singletons that should survive for the entire lifetime of the process.
  const PillarScope.global()
      : name = 'global',
        parent = null;

  /// Creates a specific sub-scope, explicitly defining its [name] and its hierarchical
  /// [parent]. To spawn a child scope quickly, prefer using the [child] method.
  const PillarScope({required this.name, required PillarScope this.parent});

  /// Spawns a new [PillarScope] instance representing a child scope of the current one.
  PillarScope child(String name) => PillarScope(name: name, parent: this);

  /// Determines if the current scope is exactly equal to the specified [scope],
  /// or if it exists hierarchically below it in the parent chain.
  ///
  /// This is deeply relied upon by [Pillar.discard] to wipe out state safely,
  /// and by [ScopeEnforcingPillarAccessor] to ensure downward visibility
  /// constraints are respected.
  bool isOrChildOf(PillarScope scope) {
    if (this == scope) return true;
    return parent?.isOrChildOf(scope) ?? false;
  }

  /// Compares the [left] and [right] scopes and returns the most restrictive
  /// (lowest in the hierarchy) scope between the two.
  ///
  /// The container uses this internally during dependency resolution to map an
  /// inferred minimum effective scope to dynamic factories. If the two scopes
  /// are disjoint (i.e., not ancestrally connected), it throws an [Exception].
  static PillarScope? chooseLowest({PillarScope? left, PillarScope? right}) {
    if (left == null) return right;
    if (right == null) return left;
    if (left.isOrChildOf(right)) return left;
    if (right.isOrChildOf(left)) return right;
    throw Exception("Two disconnected scopes can't be combined: $left, $right");
  }

  @override
  bool operator ==(Object other) =>
      other is PillarScope && name == other.name && parent == other.parent;

  @override
  int get hashCode => Object.hash(name, parent);

  @override
  String toString() => '$name PillarScope';
}
