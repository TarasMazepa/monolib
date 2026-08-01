extension OnStreamOfLists<T> on Stream<List<T>> {
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

  Stream<List<T>> _asAccumulatingSimple() async* {
    final accumulated = <T>[];
    await for (final list in this) {
      accumulated.addAll(list);
      yield accumulated;
    }
  }

  Stream<List<T>> _asAccumulatingWithRefresh() async* {
    final accumulated = <T>[];
    bool isFirstEvent = true;
    bool isRefreshing = false;

    await for (final list in this) {
      switch ((
        isEmpty: list.isEmpty,
        isFirstEvent: isFirstEvent,
        isRefreshing: isRefreshing,
      )) {
        case (isEmpty: true, isFirstEvent: true, isRefreshing: _):
          isFirstEvent = false;
          yield accumulated;
        case (isEmpty: true, isFirstEvent: false, isRefreshing: false):
          accumulated.clear();
          isRefreshing = true;
        case (isEmpty: true, isFirstEvent: false, isRefreshing: true):
          isRefreshing = false;
          yield accumulated;
        case _:
          isFirstEvent = false;
          isRefreshing = false;
          accumulated.addAll(list);
          yield accumulated;
      }
    }
  }

  /// Maps each list emitted by this stream using [mapper].
  ///
  /// If [skipMappedToEmpty] is true, non-empty lists that map to empty lists are
  /// not emitted, avoiding accidental empty list events.
  /// Incoming empty lists are preserved as-is (e.g. for refresh signals).
  Stream<List<R>> mapLists<R>(
    List<R> Function(List<T>) mapper, {
    bool skipMappedToEmpty = true,
  }) async* {
    await for (final list in this) {
      if (list.isEmpty) {
        yield <R>[];
        continue;
      }
      final mapped = mapper(list);
      if (skipMappedToEmpty && mapped.isEmpty) {
        continue;
      }
      yield mapped;
    }
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
