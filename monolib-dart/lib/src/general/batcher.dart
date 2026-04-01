import 'dart:async';

/// A highly efficient utility class for batching high-frequency incoming data.
///
/// The [Batcher] accepts items one by one and groups them into a [List].
/// It outputs this batched list via a simple callback function [onBatch],
/// avoiding the overhead of `StreamController`s.
///
/// The batch is emitted and the internal buffer cleared whenever either of
/// these two conditions is met:
/// 1. A specified [maxDuration] has passed since the first item in the current
///    batch was added. The timer is lazy (only running when there are items
///    in the buffer).
/// 2. The internal buffer reaches [maxBatchSize]. If this happens, it emits
///    immediately and resets/cancels any pending timers.
///
/// Usage Example:
/// ```dart
/// void main() async {
///   final Batcher<int> batcher = Batcher<int>(
///     maxBatchSize: 5,
///     maxDuration: const Duration(milliseconds: 100),
///     onBatch: (List<int> batch) {
///       print('Emitted batch: $batch');
///     },
///   );
///
///   for (int i = 0; i < 12; i++) {
///     batcher.add(i);
///     await Future<void>.delayed(const Duration(milliseconds: 10));
///   }
///
///   await Future<void>.delayed(const Duration(milliseconds: 150));
///   batcher.dispose();
/// }
/// ```
class Batcher<T> {
  /// The maximum number of items in a single batch.
  final int maxBatchSize;

  /// The maximum duration to wait before emitting a batch after the first item is added.
  final Duration maxDuration;

  /// The callback to invoke when a batch is ready.
  final void Function(List<T>) onBatch;

  List<T> _buffer = <T>[];
  Timer? _timer;

  /// Creates a [Batcher] that groups items into batches.
  Batcher({
    required this.maxBatchSize,
    required this.maxDuration,
    required this.onBatch,
  }) : assert(maxBatchSize > 0);

  /// Adds an item to the current batch.
  void add(T item) {
    _buffer.add(item);

    if (_buffer.length >= maxBatchSize) {
      _emit();
    } else {
      _timer ??= Timer(maxDuration, _emit);
    }
  }

  void _emit() {
    _timer?.cancel();
    _timer = null;

    if (_buffer.isNotEmpty) {
      final List<T> batch = _buffer;
      _buffer = <T>[];
      onBatch(batch);
    }
  }

  /// Cancels any active timers and immediately emits any remaining items in the buffer.
  void dispose() {
    _emit();
  }
}
