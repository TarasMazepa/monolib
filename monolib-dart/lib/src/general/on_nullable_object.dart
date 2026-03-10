extension OnNullableObject<T> on T? {
  T assertNotNull(Exception Function() exceptionProducer) =>
      this ?? (throw exceptionProducer());
}
