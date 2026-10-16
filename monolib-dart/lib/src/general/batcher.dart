/// A lightweight architectural primitive for efficiently aggregating synchronous,
/// high-frequency events into periodic asynchronous chunks.
///
/// Within the repository, [Batcher] serves as a critical decoupling layer, separating
/// eager data producers (e.g., telemetry trackers or loggers) from slow consumers
/// (e.g., disk I/O, networking, or database connections). By buffering discrete inputs
/// into a [List] and yielding them via the [onBatch] callback, it prevents I/O
/// saturation and eliminates the overhead of managing complex `StreamController` pipelines
/// for simple batch-processing workflows.
///
/// The [Batcher] emits data automatically based on size or time thresholds, ensuring
/// that in-flight [onBatch] executions run sequentially to prevent overlapping asynchronous
/// tasks (such as concurrent write collisions on an `IOSink`).
///
/// The batch is emitted and the internal buffer is cleared whenever either of the
/// following conditions are met (if configured), or when [dispose] is explicitly called:
/// 1. A specified [maxDuration] has elapsed since the first item in the current
///    batch was added. The timer evaluates lazily—it is only active when there are pending
///    items in the buffer, providing a zero-overhead footprint during idle states.
/// 2. The internal buffer capacity reaches [maxBatchSize]. When this threshold is met,
///    the [Batcher] immediately flushes its buffer and clears any active timers.
///
/// See also:
/// * `JsonlBatchWriter`, which uses [Batcher] to synchronize rapid object additions
///   into deferred disk writes in JSONL format.
///
/// Usage Example:
/// ```dart
/// // Realistic scenario: decoupling UI click events from an analytics API.
/// final analyticsBatcher = Batcher<Map<String, dynamic>>(
///   maxBatchSize: 50,
///   maxDuration: const Duration(seconds: 5),
///   onBatch: (List<Map<String, dynamic>> events) async {
///     // Invoked sequentially—safe to perform network/disk operations.
///     await api.sendEvents(events);
///   },
/// );
///
/// // Producer synchronously adds events without blocking or waiting.
/// analyticsBatcher.add({'event': 'click', 'target': 'login_btn'});
/// analyticsBatcher.add({'event': 'scroll', 'depth': 80});
///
/// // Safely flushes pending events and releases resources on shutdown.
/// await analyticsBatcher.dispose();
/// ```
library;

import 'dart:async';

class Batcher<T> {
  /// The maximum item capacity required to trigger an immediate batch emission.
  ///
  /// If set to `null`, the [Batcher] will never emit based on accumulation size
  /// and will rely entirely on [maxDuration] or explicit [dispose] calls.
  final int? maxBatchSize;

  /// The maximum temporal window before a pending batch is forcibly emitted.
  ///
  /// The timer begins ticking lazily when the first item is added to an empty buffer.
  /// If set to `null`, the [Batcher] ignores time-based constraints.
  final Duration? maxDuration;

  /// A user-provided callback that processes the aggregated sequence of items.
  ///
  /// This function is invoked sequentially. The [Batcher] guarantees that a new
  /// execution of [onBatch] will not commence until the `Future` returned by the
  /// previous execution has completed. This protects stateful resources (like file sinks
  /// or network connections) from concurrent modifications.
  final FutureOr<void> Function(List<T>) onBatch;

  /// Dictates the error-handling strategy when items are added after shutdown.
  ///
  /// When `true`, invoking [add] on a disposed instance throws a [StateError].
  /// When `false`, extraneous items are silently ignored (useful in unpredictable
  /// event streams where shutdown race conditions might occur).
  final bool throwOnAddAfterDispose;

  List<T> _buffer = <T>[];
  Timer? _timer;
  bool _isDisposed = false;
  final List<Future<void>> _inflightBatches = <Future<void>>[];
  Future<void>? _lastBatchTask;

  /// Instantiates a new [Batcher] with the defined flushing heuristics.
  ///
  /// Must provide a valid [onBatch] callback to handle the aggregated outputs.
  /// The constraints [maxBatchSize] and [maxDuration] dictate the triggering logic.
  /// [throwOnAddAfterDispose] defines behavior when [add] is called post-termination.
  ///
  /// Asserts that [maxBatchSize] is either `null` or strictly greater than zero.
  Batcher({
    this.maxBatchSize,
    this.maxDuration,
    required this.onBatch,
    this.throwOnAddAfterDispose = true,
  }) : assert(maxBatchSize == null || maxBatchSize > 0);

  /// Synchronously enqueues an [item] into the internal aggregation buffer.
  ///
  /// This method performs no blocking operations. If the addition causes the buffer
  /// to reach [maxBatchSize], an asynchronous flush is triggered instantly.
  /// Otherwise, if [maxDuration] is configured, a lazy expiration timer is initiated.
  ///
  /// If [dispose] has already been called and [throwOnAddAfterDispose] is `true`,
  /// this method throws a [StateError]. If [throwOnAddAfterDispose] is `false`,
  /// the [item] is silently discarded.
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
        await onBatch(batch);
      } finally {
        completer.complete();
      }
    });

    _inflightBatches.add(batchTask);
    unawaited(batchTask.whenComplete(() => _inflightBatches.remove(batchTask)));

    await batchTask;
  }

  /// Gracefully terminates the [Batcher] and finalizes its pending state.
  ///
  /// Calling this method cancels any active timers, forces an immediate emission
  /// of any remaining items in the buffer via [onBatch], and awaits the completion
  /// of all in-flight asynchronous operations.
  ///
  /// This ensures that critical resources (like open file handles writing JSONL data)
  /// are not closed or corrupted while batches are still actively processing.
  Future<void> dispose() async {
    _isDisposed = true;
    await _emit();
    await _inflightBatches.wait;
  }
}
