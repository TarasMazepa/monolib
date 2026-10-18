import 'package:monolib_dart/src/general/on_empty_iterator.dart';

/// A lazy [Iterable] wrapper that invokes a callback when iteration produces no
/// elements.
///
/// Used by the `onEmpty` extension method on `OnIterable` to detect an empty
/// sequence during a single iteration pass, avoiding a separate `isEmpty` check
/// on lazy or single-subscription sequences. Delegates iteration to
/// [OnEmptyIterator].
///
/// Example:
/// ```dart
/// final numbers = <int>[];
/// final iterable = OnEmptyIterable(
///   numbers,
///   () => print('The sequence was empty!'),
/// );
///
/// for (final number in iterable) {
///   print(number);
/// }
/// ```
class OnEmptyIterable<T> extends Iterable<T> {
  final Iterable<T> _source;

  final void Function() _onEmpty;

  /// Creates an [OnEmptyIterable] that wraps the source iterable and invokes
  /// the given callback if iterating it yields no elements.
  OnEmptyIterable(this._source, this._onEmpty);

  /// Returns an [OnEmptyIterator] over the source iterable that invokes the
  /// callback if the first call to [Iterator.moveNext] returns `false`.
  @override
  Iterator<T> get iterator => OnEmptyIterator(_source.iterator, _onEmpty);
}
