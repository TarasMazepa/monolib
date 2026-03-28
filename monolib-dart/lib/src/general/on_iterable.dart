import 'on_empty_iterable.dart';

extension OnIterable<T> on Iterable<T> {
  Iterable<T> onEmpty(void Function() onEmpty) {
    return OnEmptyIterable(this, onEmpty);
  }
}
