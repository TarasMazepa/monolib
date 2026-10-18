/// An [Iterator] wrapper that invokes a callback when iteration produces no
/// elements.
///
/// Used by `OnEmptyIterable` and the `onEmpty` extension method on `OnIterable`
/// to detect an empty sequence during a single iteration pass, avoiding a
/// separate `isEmpty` check on lazy or single-subscription sequences.
///
/// Example:
/// ```dart
/// final numbers = <int>[];
/// final iterator = OnEmptyIterator(
///   numbers.iterator,
///   () => print('The sequence was empty!'),
/// );
///
/// while (iterator.moveNext()) {
///   print(iterator.current);
/// }
/// ```
class OnEmptyIterator<T> implements Iterator<T> {
  final Iterator<T> _source;

  final void Function() _onEmpty;

  bool _hadElement = false;

  /// Creates an [OnEmptyIterator] that wraps the source iterator and invokes
  /// the given callback if iterating it yields no elements.
  OnEmptyIterator(this._source, this._onEmpty);

  /// The current element of the underlying iterator.
  @override
  T get current => _source.current;

  /// Advances the iterator to the next element.
  ///
  /// Returns `true` if the underlying iterator has a next element. If the
  /// underlying iterator is immediately exhausted on the first call without
  /// yielding any elements, invokes the empty callback before returning
  /// `false`.
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
