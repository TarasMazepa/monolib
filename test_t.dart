T testSum<T>({T? zero}) {
  if (zero != null) return zero;
  if (T == int) return 0 as T;
  if (T == double) return 0.0 as T;
  if (T == num) return 0 as T;
  throw StateError('empty');
}

void main() {
  print(testSum<int>());
  print(testSum<double>());
  print(testSum<num>());
  try {
    testSum<String>();
  } catch (e) {
    print(e);
  }
}
