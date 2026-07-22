import 'dart:async';

extension StreamLastOrNullExtension<T> on Stream<T> {
  /// Returns the last element of the stream, or `null` if the stream is empty.
  Future<T?> get lastOrNull {
    final completer = Completer<T?>();
    T? result;

    listen(
      (event) {
        result = event;
      },
      onError: completer.completeError,
      onDone: () {
        completer.complete(result);
      },
      cancelOnError: true,
    );

    return completer.future;
  }
}
