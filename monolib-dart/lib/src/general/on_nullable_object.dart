extension OnNullableObject<T> on T? {
  T assertNotNull(Exception Function() exceptionProducer) =>
      this ?? (throw exceptionProducer());

  bool isIn(Set<T> set) {
    return set.contains(this);
  }
}
