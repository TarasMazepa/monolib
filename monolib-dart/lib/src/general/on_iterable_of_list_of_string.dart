extension OnIterableOfListOfString on Iterable<List<String>> {
  Iterable<List<String>> skipFirstIfIsCsvHeaderRow({
    required bool Function(List<String>) isCsvHeaderRow,
  }) sync* {
    final iterator = this.iterator;
    if (!iterator.moveNext()) {
      return;
    }
    final first = iterator.current;
    if (!isCsvHeaderRow(first)) {
      yield first;
    }
    while (iterator.moveNext()) {
      yield iterator.current;
    }
  }
}
