import 'dart:async';

/// A buffer that aggregates synchronous items and flushes them in periodic or
/// size-bounded batches.
///
/// Collects items added via [add] into a [List] and passes each batch to
/// [onBatch] whenever:
/// 1. The number of buffered items reaches [maxBatchSize], or
/// 2. [maxDuration] has elapsed since the first item in the current batch was
///    added (the timer is started lazily only while the buffer is non-empty), or
/// 3. [dispose] is called.
///
/// Batch callbacks are serialized so that each [onBatch] invocation waits for
/// the previous batch's [Future] to complete before running.
///
/// Example:
/// ```dart
/// final analyticsBatcher = Batcher<Map<String, dynamic>>(
///   maxBatchSize: 50,
///   maxDuration: const Duration(seconds: 5),
///   onBatch: (List<Map<String, dynamic>> events) async {
///     await api.sendEvents(events);
///   },
/// );
///
/// analyticsBatcher.add({'event': 'click', 'target': 'login_btn'});
/// analyticsBatcher.add({'event': 'scroll', 'depth': 80});
///
/// await analyticsBatcher.dispose();
/// ```
class Batcher<T> {
  final int? _maxBatchSize;
  final Duration? _maxDuration;
  final FutureOr<void> Function(List<T>) _onBatch;
  final bool _throwOnAddAfterDispose;

  List<T> _buffer = <T>[];
  Timer? _timer;
  bool _isDisposed = false;
  final List<Future<void>> _inflightBatches = <Future<void>>[];
  Future<void>? _lastBatchTask;

  /// Creates a [Batcher] that flushes buffered items to [onBatch].
  ///
  /// If provided, [maxBatchSize] must be greater than zero.
  Batcher({
    int? maxBatchSize,
    Duration? maxDuration,
    required FutureOr<void> Function(List<T>) onBatch,
    bool throwOnAddAfterDispose = true,
  })  : assert(maxBatchSize == null || maxBatchSize > 0),
        _maxBatchSize = maxBatchSize,
        _maxDuration = maxDuration,
        _onBatch = onBatch,
        _throwOnAddAfterDispose = throwOnAddAfterDispose;

  /// Adds [item] to the current batch buffer.
  ///
  /// If the buffer reaches [maxBatchSize], a flush is triggered immediately.
  /// Otherwise, if [maxDuration] is set, a timer is started if one is not
  /// already active.
  ///
  /// Throws a [StateError] if [dispose] has already been called and
  /// [throwOnAddAfterDispose] is `true`.
  void add(T item) {
    if (_isDisposed) {
      if (_throwOnAddAfterDispose) {
        throw StateError('Cannot add items to a disposed Batcher.');
      }
      return;
    }

    _buffer.add(item);

    if (_maxBatchSize != null && _buffer.length >= _maxBatchSize) {
      unawaited(_emit());
    } else if (_maxDuration != null) {
      _timer ??= Timer(_maxDuration, _emit);
    }
  }

  Future<void> _emit() async {
    _timer?.cancel();
    _timer = null;

    if (_buffer.isEmpty) return;

    final List<T> batch = _buffer;
    _buffer = <T>[];

    final previousTask = _lastBatchTask;
    final completer = Completer<void>();
    _lastBatchTask = completer.future;

    final Future<void> batchTask = Future<void>.sync(() async {
      try {
        if (previousTask != null) {
          await previousTask;
        }
        await _onBatch(batch);
      } finally {
        completer.complete();
      }
    });

    _inflightBatches.add(batchTask);
    unawaited(batchTask.whenComplete(() => _inflightBatches.remove(batchTask)));

    await batchTask;
  }

  /// Disposes this batcher, flushing any remaining buffered items and awaiting
  /// all in-flight [onBatch] operations.
  Future<void> dispose() async {
    _isDisposed = true;
    await _emit();
    await _inflightBatches.wait;
  }
}
