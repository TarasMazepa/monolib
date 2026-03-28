extension OnIterableOfNum on Iterable<num> {
  Iterable<double> operator /(num divisor) => map((item) => item / divisor);
}
