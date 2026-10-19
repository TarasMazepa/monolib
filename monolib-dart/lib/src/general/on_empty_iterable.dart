import 'package:monolib_dart/src/general/on_empty_iterator.dart';

/// Internal lazy [Iterable] wrapper used by `onEmpty` that invokes a callback
/// when iteration yields no elements.
class OnEmptyIterable<T> extends Iterable<T> {
  final Iterable<T> _source;

  final void Function() _onEmpty;

  /// Creates an [OnEmptyIterable] wrapping the source iterable.
  OnEmptyIterable(this._source, this._onEmpty);

  @override
  Iterator<T> get iterator => OnEmptyIterator(_source.iterator, _onEmpty);
}
