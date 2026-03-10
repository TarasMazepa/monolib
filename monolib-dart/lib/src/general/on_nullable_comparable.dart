extension OnNullableComparable<T> on Comparable<T>? {
  int compare(T? other) => switch ((this, other)) {
    (final a?, final b?) => a.compareTo(b),
    (null, null) => 0,
    (null, _) => -1,
    (_, null) => 1,
  };
}
