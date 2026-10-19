/// Internal [Iterator] wrapper that invokes a callback when iteration produces
/// no elements.
class OnEmptyIterator<T> implements Iterator<T> {
  final Iterator<T> _source;

  final void Function() _onEmpty;

  bool _hadElement = false;

  /// Creates an [OnEmptyIterator] wrapping the source iterator.
  OnEmptyIterator(this._source, this._onEmpty);

  @override
  T get current => _source.current;

  @override
  bool moveNext() {
    if (_source.moveNext()) {
      _hadElement = true;
      return true;
    } else {
      if (!_hadElement) _onEmpty();
      return false;
    }
  }
}
