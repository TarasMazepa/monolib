class PillarScope {
  final String name;
  final PillarScope? parent;

  const PillarScope.global() : name = 'global', parent = null;

  const PillarScope({required this.name, required PillarScope this.parent});

  PillarScope child(String name) => PillarScope(name: name, parent: this);

  bool isOrChildOf(PillarScope scope) {
    if (this == scope) return true;
    return parent?.isOrChildOf(scope) ?? false;
  }

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
