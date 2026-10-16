/// An [Iterator] wrapper that intercepts iteration to trigger a callback if the
/// sequence is completely empty.
///
/// This class serves as the underlying implementation for `OnEmptyIterable`,
/// which is exposed to consumers via the `onEmpty` extension method on [Iterable]
/// (found in `OnIterable`). Its architectural purpose is to allow developers to
/// lazily detect and handle empty states during a single pass of iteration, rather
/// than requiring a preemptive `.isEmpty` check that might consume an iterator
/// or incur unnecessary performance costs on lazy sequences.
///
/// Per the repository's rules for lifecycle flows and callbacks, the [_onEmpty]
/// callback is deliberately not guarded by a try-catch block. If the user-provided
/// callback throws an exception, it is allowed to propagate naturally back to the
/// caller.
///
/// Example usage (usually accessed via the extension):
/// ```dart
/// final numbers = <int>[];
/// final iterable = numbers.onEmpty(() => print('The sequence was empty!'));
///
/// // Iterating will trigger the callback since there are no elements.
/// for (final number in iterable) {
///   print(number);
/// }
/// ```
class OnEmptyIterator<T> implements Iterator<T> {
  /// The underlying [Iterator] from which elements are sourced.
  final Iterator<T> _source;

  /// The callback to invoke when [_source] is exhausted without yielding any elements.
  ///
  /// This function is only executed once, immediately after the first call to
  /// [moveNext] returns `false`.
  final void Function() _onEmpty;

  /// Tracks whether the iterator has successfully yielded at least one element.
  bool _hadElement = false;

  /// Creates a new [OnEmptyIterator] that wraps the given [_source] iterator
  /// and triggers [_onEmpty] if the iteration yields no elements.
  OnEmptyIterator(this._source, this._onEmpty);

  /// Returns the current element from the underlying [_source] iterator.
  ///
  /// The behavior is identical to the wrapped [Iterator.current], meaning it
  /// should only be accessed after [moveNext] has returned `true`.
  @override
  T get current => _source.current;

  /// Advances the iterator to the next element.
  ///
  /// If the underlying [_source] yields an element, it records that the sequence
  /// is not empty and returns `true`. If the sequence is immediately exhausted
  /// on the first call (i.e., [_hadElement] remains `false`), it invokes the
  /// [_onEmpty] callback before returning `false`.
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
