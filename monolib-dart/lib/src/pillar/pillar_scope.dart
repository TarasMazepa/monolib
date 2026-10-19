/// Represents a hierarchical lifecycle boundary within the Pillar dependency injection framework.
///
/// A [PillarScope] dictates how long an instance lives and dictates dependency
/// resolution rules. It is primarily used to prevent a longer-lived object
/// (e.g., a global singleton) from holding onto a shorter-lived object (e.g.,
/// an active session), which would create a memory leak or stale state.
///
/// In practice, you declare scopes hierarchically. When an instance is
/// registered via `Pillar.register` with a specific scope, the framework tracks it.
/// If a lower-scoped instance (e.g., `userScope`) is requested by a higher-scoped
/// instance (e.g., `globalScope`), a scope enforcement exception is thrown.
///
/// Scopes also act as boundaries for invalidation. Calling `Pillar.discard` or
/// `Pillar.replace` with a [PillarScope] clears or replaces all cached instances
/// associated with that scope and its children, allowing developers to reset
/// states cleanly (e.g., upon user logout).
///
/// Example:
/// ```dart
/// const PillarScope appScope = PillarScope.global();
/// final PillarScope sessionScope = appScope.child('session');
///
/// // Later, when replacing a dependency specifically for the session:
/// pillar.replace(instance: newSessionConfig, scope: sessionScope);
/// ```
class PillarScope {
  /// The descriptive name of this scope, primarily used for debugging and logging.
  final String name;

  /// The parent boundary of this scope, or `null` if this is the root.
  ///
  /// A scope is considered a child (or descendant) of its parent, meaning it
  /// has a shorter lifecycle and is allowed to depend on its parent's dependencies,
  /// but not the other way around.
  final PillarScope? parent;

  /// Creates a root-level global scope with the name 'global' and no parent.
  ///
  /// This is typically used for singletons that should live for the entire
  /// duration of the application.
  const PillarScope.global()
      : name = 'global',
        parent = null;

  /// Creates a custom [PillarScope] with a specific [name] and [parent].
  ///
  /// In most cases, it's more convenient to use the [child] method on an
  /// existing scope rather than calling this constructor directly.
  const PillarScope({required this.name, required PillarScope this.parent});

  /// Derives a new, more restrictive child scope from `this` scope.
  ///
  /// The resulting child scope will have `this` as its [parent].
  ///
  /// Example:
  /// ```dart
  /// final PillarScope routeScope = appScope.child('route');
  /// ```
  PillarScope child(String name) => PillarScope(name: name, parent: this);

  /// Checks if `this` scope is the same as, or a descendant of, the provided [scope].
  ///
  /// This validates hierarchical access rules. For example, if a `sessionScope`
  /// is a child of `appScope`, `sessionScope.isOrChildOf(appScope)` returns `true`,
  /// but `appScope.isOrChildOf(sessionScope)` returns `false`.
  bool isOrChildOf(PillarScope scope) {
    if (this == scope) return true;
    return parent?.isOrChildOf(scope) ?? false;
  }

  /// Compares this scope to [other] by comparing their names and parents.
  @override
  bool operator ==(Object other) =>
      other is PillarScope && name == other.name && parent == other.parent;

  /// Computes a hash code based on [name] and [parent].
  @override
  int get hashCode => Object.hash(name, parent);

  /// Returns a string representation of the scope, useful for debugging errors.
  @override
  String toString() => '$name PillarScope';
}
