extension OnInt on int {
  /// Converts a standard -1 "not found" index to null.
  int? get asNullableIndex => this == -1 ? null : this;
}
