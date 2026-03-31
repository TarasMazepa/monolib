extension OnFutureFunction<T> on Future<T> Function() {
  Future<T> asyncCallWithRetryOnFailure({int times = 3}) async {
    dynamic toRethrow;
    for (int i = 0; i < times && times > 0; i++) {
      try {
        return await this();
      } catch (e) {
        toRethrow ??= e;
      }
    }
    throw toRethrow;
  }
}

Future<T> asyncRetryOnFailure<T>(Future<T> Function() call, {int times = 3}) {
  return call.asyncCallWithRetryOnFailure(times: times);
}
