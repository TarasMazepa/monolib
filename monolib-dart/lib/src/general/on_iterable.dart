import 'package:monolib_dart/src/general/on_empty_iterable.dart';

extension OnIterable<T> on Iterable<T> {
  Iterable<T> onEmpty(void Function() onEmpty) {
    return OnEmptyIterable(this, onEmpty);
  }

  T sum() {
    final iterator = this.iterator;
    if (!iterator.moveNext()) {
      throw StateError("Empty iterable can't be summed");
    }
    dynamic result = iterator.current;
    while (iterator.moveNext()) {
      result += iterator.current;
    }
    return result;
  }

  R sumBy<R>(R Function(T) mapper) {
    final iterator = this.iterator;
    if (!iterator.moveNext()) {
      throw StateError("Empty iterable can't be summed");
    }
    dynamic result = mapper(iterator.current);
    while (iterator.moveNext()) {
      result += mapper(iterator.current);
    }
    return result;
  }
}
