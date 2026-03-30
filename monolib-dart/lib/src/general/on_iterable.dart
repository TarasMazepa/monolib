import 'on_empty_iterable.dart';

extension OnIterable<T> on Iterable<T> {
  Iterable<T> onEmpty(void Function() onEmpty) {
    return OnEmptyIterable(this, onEmpty);
  }

  Iterable<R> mapCatching<R>(
    R Function(T) mapping, {
    void Function(Object error, T item)? onError,
  }) sync* {
    for (final item in this) {
      try {
        yield mapping(item);
      } catch (e) {
        if (onError != null) {
          onError(e, item);
        }
      }
    }
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
