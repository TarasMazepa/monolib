extension OnComparable<T extends Comparable<dynamic>> on T {
  int? compareChain(T other) {
    final result = compareTo(other);
    return result == 0 ? null : result;
  }
}
