import 'package:monolib_dart/src/general/on_empty_iterator.dart';

/// A lazily-evaluated [Iterable] wrapper that intercepts iteration to trigger a
/// callback if the underlying sequence is completely empty.
///
/// Architecturally, this class powers the `onEmpty` extension method on [Iterable]
/// (found in `OnIterable`). It enables developers to execute side effects or error
/// handling (such as logging warnings, updating UI state, or recording analytics)
/// precisely when a sequence yields no elements. Crucially, it does this during a
/// single iteration pass, avoiding the performance penalties or consumption issues
/// associated with calling `isEmpty` preemptively on lazily evaluated or
/// single-subscription sequences (like streams converted to iterables).
///
/// It achieves this by delegating to [OnEmptyIterator], which performs the actual
/// stateful check on the first call to `moveNext()`.
///
/// Example usage (typically accessed via the extension):
/// ```dart
/// Iterable<String> fetchLogs() sync* {
///   // Imagine this sequence yields no elements.
/// }
///
/// final logs = fetchLogs().onEmpty(() {
///   print('Warning: No logs were found during the scan.');
/// });
///
/// // The emptiness check happens naturally during iteration:
/// for (final log in logs) {
///   print('Log entry: $log');
/// }
/// ```
class OnEmptyIterable<T> extends Iterable<T> {
  /// The underlying [Iterable] from which elements are lazily sourced.
  final Iterable<T> _source;

  /// The callback to invoke if iterating through [_source] yields zero elements.
  ///
  /// This is passed down to [OnEmptyIterator], and exceptions thrown within this
  /// callback intentionally propagate to the caller.
  final void Function() _onEmpty;

  /// Wraps the given [_source] iterable with an emptiness trap, executing
  /// [_onEmpty] if a consumer iterates it and finds no elements.
  OnEmptyIterable(this._source, this._onEmpty);

  /// Returns an [OnEmptyIterator] state machine that manages the iteration
  /// process and intercepts the initial [Iterator.moveNext] call to determine
  /// if [_onEmpty] should be executed.
  @override
  Iterator<T> get iterator => OnEmptyIterator(_source.iterator, _onEmpty);
}
