import 'dart:async';

/// Extension on [Stream] of [List] that provides flattening, accumulation,
/// batch mapping, and element filtering utilities.
extension OnStreamOfLists<T> on Stream<List<T>> {
  /// Collects all lists emitted by this stream into a single flattened [List].
  ///
  /// - [cancelOnError]: If `true` (the default), cancels the subscription on
  ///   the first error and completes the returned [Future] with that error. If
  ///   `false`, continues draining the stream while still completing the
  ///   returned [Future] with the first error encountered.
  /// - [sync]: If `true`, uses a synchronous [Completer] (`Completer.sync()`).
  ///   Defaults to `false`.
  ///
  /// Example:
  /// ```dart
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

  /// Transforms this stream to emit a cumulatively growing list containing all
  /// elements from chunks received so far.
  ///
  /// If [emptyMeansRefresh] is `true`, an incoming empty list `[]` clears the
  /// accumulated buffer and resets accumulation for subsequent events.
  ///
  /// Note: The same internal [List] instance is mutated and emitted on each
  /// event. Create a copy (for example, `[...event]`) if you need to retain
  /// immutable snapshots across emissions.
  ///
  /// Example:
  /// ```dart
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

  /// Transforms each non-empty list chunk emitted by this stream using
  /// [mapper].
  ///
  /// If [skipMappedToEmpty] is `true` (the default), any non-empty input list
  /// that maps to an empty list is omitted from the output stream, whereas
  /// empty lists emitted by the source stream (such as refresh signals for
  /// [asAccumulating]) are passed through as empty lists.
  ///
  /// Example:
  /// ```dart
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

  /// Filters elements in each emitted list in place using [predicate].
  ///
  /// Mutates each incoming list via [List.retainWhere] so that only elements
  /// satisfying [predicate] remain. If [predicate] is `null`, returns this
  /// stream unchanged.
  ///
  /// Uses [mapLists] internally: when [skipMappedToEmpty] is `true` (the
  /// default), non-empty chunks whose elements are all removed by [predicate]
  /// are omitted from the output stream.
  ///
  /// Example:
  /// ```dart
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
