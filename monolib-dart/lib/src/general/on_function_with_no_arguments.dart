extension OnFunctionWithNoArguments<T> on T Function() {
  T callWithRetryOnFailure({int times = 3}) {
    dynamic toRethrow;
    for (int i = 0; i < times && times > 0; i++) {
      try {
        return this();
      } catch (e) {
        toRethrow ??= e;
      }
    }
    throw toRethrow;
  }
}

T retryOnFailure<T>(T Function() call, {int times = 3}) {
  return call.callWithRetryOnFailure(times: times);
}
