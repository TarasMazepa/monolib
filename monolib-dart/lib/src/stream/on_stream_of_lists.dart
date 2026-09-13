import 'dart:async';

extension OnStreamOfLists<T> on Stream<List<T>> {
  /// Gathers all lists emitted by this stream and flattens them into a single list.
  ///
  /// - [cancelOnError]: If `true` (default), the stream subscription is cancelled
  ///   immediately upon the first error. If `false`, the stream continues to drain
  ///   in the background, but the returned Future completes with the first error.
  /// - [sync]: If `true`, the internal Completer is created as `Completer.sync()`,
  ///   completing the Future synchronously upon the stream's `onDone` event.
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

  /// Accumulates the lists emitted by this stream into a single list.
  ///
  /// Note: This yields the same [List] instance on every event, so consumers
  /// should be careful not to hold onto old references if they expect them
  /// to remain unchanged, or mutate the list.
  Stream<List<T>> asAccumulating({bool emptyMeansRefresh = false}) {
    if (emptyMeansRefresh) {
      return _asAccumulatingWithRefresh();
    }
    return _asAccumulatingSimple();
  }

  Stream<List<T>> _asAccumulatingSimple() {
    return transform(StreamTransformer.fromBind((stream) {
      final accumulated = <T>[];
      return stream.map((list) {
        accumulated.addAll(list);
        return accumulated;
      });
    }));
  }

  Stream<List<T>> _asAccumulatingWithRefresh() {
    return transform(StreamTransformer.fromBind((stream) {
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
    }));
  }

  /// Maps each list emitted by this stream using [mapper].
  ///
  /// If [skipMappedToEmpty] is true, non-empty lists that map to empty lists are
  /// not emitted, avoiding accidental empty list events.
  /// Incoming empty lists are preserved as-is (e.g. for refresh signals).
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

  /// Filters the elements in each list emitted by this stream using [predicate].
  ///
  /// If [predicate] is null, this stream is returned unchanged.
  ///
  /// If [skipMappedToEmpty] is true, when all elements in a non-empty list are
  /// filtered out, the resulting empty list is not emitted.
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
