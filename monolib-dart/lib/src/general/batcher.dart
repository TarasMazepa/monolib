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
  /// If null, the batcher will not emit based on size.
  final int? maxBatchSize;

  /// The maximum duration to wait before emitting a batch after the first item is added.
  /// If null, the batcher will not emit based on duration.
  final Duration? maxDuration;

  /// The callback to invoke when a batch is ready.
  final FutureOr<void> Function(List<T>) onBatch;

  /// Whether to throw a [StateError] if items are added after the batcher is disposed.
  final bool throwOnAddAfterDispose;

  List<T> _buffer = <T>[];
  Timer? _timer;
  bool _isDisposed = false;
  final List<Future<void>> _inflightBatches = <Future<void>>[];

  /// Creates a [Batcher] that groups items into batches.
  Batcher({
    this.maxBatchSize,
    this.maxDuration,
    required this.onBatch,
    this.throwOnAddAfterDispose = true,
  }) : assert(maxBatchSize == null || maxBatchSize > 0);

  /// Adds an item to the current batch.
  void add(T item) {
    if (_isDisposed) {
      if (throwOnAddAfterDispose) {
        throw StateError('Cannot add items to a disposed Batcher.');
      }
      return;
    }

    _buffer.add(item);

    if (maxBatchSize != null && _buffer.length >= maxBatchSize!) {
      unawaited(_emit());
    } else if (maxDuration != null) {
      _timer ??= Timer(maxDuration!, _emit);
    }
  }

  Future<void> _emit() async {
    _timer?.cancel();
    _timer = null;

    if (_buffer.isNotEmpty) {
      final List<T> batch = _buffer;
      _buffer = <T>[];

      late Future<void> future;
      future = Future<void>.sync(() async {
        try {
          await onBatch(batch);
        } finally {
          _inflightBatches.remove(future);
        }
      });
      _inflightBatches.add(future);

      await future;
    }
  }

  /// Cancels any active timers and immediately emits any remaining items in the buffer.
  Future<void> dispose() async {
    _isDisposed = true;
    await <Future<void>>[_emit(), ..._inflightBatches].wait;
  }
}
