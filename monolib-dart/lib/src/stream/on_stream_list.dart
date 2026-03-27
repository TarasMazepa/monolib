extension OnStreamList<T> on Stream<List<T>> {
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
}
