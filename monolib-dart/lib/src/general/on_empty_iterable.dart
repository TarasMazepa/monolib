import 'on_empty_iterator.dart';

class OnEmptyIterable<T> extends Iterable<T> {
  final Iterable<T> _source;
  final void Function() _onEmpty;

  OnEmptyIterable(this._source, this._onEmpty);

  @override
  Iterator<T> get iterator => OnEmptyIterator(_source.iterator, _onEmpty);
}
