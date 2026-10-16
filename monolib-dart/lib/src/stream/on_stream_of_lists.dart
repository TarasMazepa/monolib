import 'dart:async';

/// An architectural extension providing functional transformation and aggregation
/// utilities for stream pipelines emitting chunked or batched payloads, such as
/// paginated API results, bulk database queries, or buffered event streams.
///
/// This extension enables expressive, fluid chaining of operations on
/// `Stream<List<T>>` to consolidate fragmented payloads into continuous lists,
/// accumulate historical events, or project transformations across nested collections
/// without writing manual nested stream mappers.
extension OnStreamOfLists<T> on Stream<List<T>> {
  /// Consolidates all lists asynchronously emitted by this stream into a single
  /// fully-buffered list, typically used to aggregate chunked file reads or paginated
  /// data into memory once the stream completes.
  ///
  /// - [cancelOnError]: If `true` (default), the underlying stream subscription is
  ///   immediately cancelled upon encountering the first error, and the returned
  ///   future completes with that error. If `false`, the stream silently continues
  ///   to drain remaining background events, but the returned [Future] still completes
  ///   with the earliest encountered error.
  /// - [sync]: If `true`, the internal [Completer] operates synchronously. This causes
  ///   the returned [Future] to complete within the same microtask as the stream's
  ///   `onDone` event, prioritizing immediate continuation for tight execution loops.
  ///   Defaults to `false`.
  ///
  /// ```dart
  /// // Gathers batched CSV rows into a final dense table structure.
  /// final Stream<List<String>> rowStream = readCsvRows();
  /// final List<String> allRows = await rowStream.flattenToList();
  /// ```
  Future<List<T>> flattenToList({
    bool cancelOnError = true,
    bool sync = false,
  }) {
    final completer = sync ? Completer<List<T>>.sync() : Completer<List<T>>();
    final accumulated = <T>[];

    listen(
      (list) {
        if (!completer.isCompleted) {
          accumulated.addAll(list);
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        if (!completer.isCompleted) {
          completer.completeError(error, stackTrace);
        }
      },
      onDone: () {
        if (!completer.isCompleted) {
          completer.complete(accumulated);
        }
      },
      cancelOnError: cancelOnError,
    );

    return completer.future;
  }

  /// Transforms the stream to emit a progressively growing list that retains all
  /// elements from previously emitted chunks, serving as a stateful aggregator
  /// for cumulative logs or infinite scrolling models.
  ///
  /// If [emptyMeansRefresh] is `true`, an incoming empty list `[]` acts as a
  /// flush signal. It clears the ongoing accumulation state and emits a fresh
  /// empty list, seamlessly resetting the buffer without tearing down the stream.
  ///
  /// **Warning:** For performance optimization, the *same* [List] instance is mutated
  /// and yielded on every event. Consumers (like reactive UI builders) should use
  /// the spread operator (`[...event]`) to create defensive copies if they need to
  /// compare sequential states or retain historical snapshots.
  ///
  /// ```dart
  /// // Incrementally build a chat message history as batches arrive.
  /// streamOfBatches
  ///   .asAccumulating(emptyMeansRefresh: true)
  ///   .listen((allMessages) => renderUI(allMessages));
  /// ```
  Stream<List<T>> asAccumulating({bool emptyMeansRefresh = false}) {
    if (emptyMeansRefresh) {
      return _asAccumulatingWithRefresh();
    }
    return _asAccumulatingSimple();
  }

  Stream<List<T>> _asAccumulatingSimple() {
    return transform(
      StreamTransformer.fromBind((stream) {
        final accumulated = <T>[];
        return stream.map((list) {
          accumulated.addAll(list);
          return accumulated;
        });
      }),
    );
  }

  Stream<List<T>> _asAccumulatingWithRefresh() {
    return transform(
      StreamTransformer.fromBind((stream) {
        final accumulated = <T>[];
        bool isFirstEvent = true;
        bool isRefreshing = false;

        return stream.expand((list) {
          switch ((
            isEmpty: list.isEmpty,
            isFirstEvent: isFirstEvent,
            isRefreshing: isRefreshing,
          )) {
            case (isEmpty: true, isFirstEvent: true, isRefreshing: _):
              isFirstEvent = false;
              return [accumulated];
            case (isEmpty: true, isFirstEvent: false, isRefreshing: false):
              accumulated.clear();
              isRefreshing = true;
              return const [];
            case (isEmpty: true, isFirstEvent: false, isRefreshing: true):
              isRefreshing = false;
              return [accumulated];
            case _:
              isFirstEvent = false;
              isRefreshing = false;
              accumulated.addAll(list);
              return [accumulated];
          }
        });
      }),
    );
  }

  /// Applies a projection [mapper] across each batched chunk emitted by the stream,
  /// generating a new stream of structurally modified lists.
  ///
  /// If [skipMappedToEmpty] is `true` (the default), any non-empty input chunk that
  /// becomes completely empty after mapping is suppressed. This avoids polluting
  /// the downstream pipeline with accidental "ghost" events caused by exhaustive
  /// filtering. Conversely, explicitly emitted empty chunks from the source stream
  /// (such as deliberate refresh signals handled by [asAccumulating]) are intentionally
  /// preserved and passed through.
  ///
  /// ```dart
  /// // Parse raw JSON dict batches into domain models.
  /// jsonListStream.mapLists((batch) {
  ///   return batch.map((json) => User.fromJson(json)).toList();
  /// });
  /// ```
  Stream<List<R>> mapLists<R>(
    List<R> Function(List<T>) mapper, {
    bool skipMappedToEmpty = true,
  }) {
    return expand((list) {
      if (list.isEmpty) {
        return const [[]];
      }
      final mapped = mapper(list);
      if (skipMappedToEmpty && mapped.isEmpty) {
        return const [];
      }
      return [mapped];
    });
  }

  /// Non-destructively retains elements in each batched chunk that satisfy the
  /// Boolean [predicate], acting as an inline batch-filter.
  ///
  /// If [predicate] is dynamically resolved to `null`, the stream bypasses filtering
  /// entirely and returns itself unchanged, optimizing out unnecessary list cloning.
  ///
  /// Operates using [mapLists] internally, meaning the [skipMappedToEmpty] flag
  /// applies identical logic: non-empty chunks that are entirely filtered out will
  /// be dropped from the stream to prevent spurious empty triggers.
  ///
  /// ```dart
  /// // Exclude disabled items before processing a bulk update.
  /// itemBatches.whereElements((item) => item.isActive);
  /// ```
  Stream<List<T>> whereElements(
    bool Function(T)? predicate, {
    bool skipMappedToEmpty = true,
  }) {
    if (predicate == null) {
      return this;
    }
    return mapLists(
      (list) => list..retainWhere(predicate),
      skipMappedToEmpty: skipMappedToEmpty,
    );
  }
}
