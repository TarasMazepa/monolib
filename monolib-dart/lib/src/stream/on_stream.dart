import 'dart:async';

extension OnStream<T> on Stream<T> {
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

  /// Maps the elements of the stream to a new type `R` using [mapper].
  /// Tracks the mapped values and returns the last non-null mapped value,
  /// or `null` if the stream is empty or if all mapped values were `null`.
  Future<R?> mappedLastOrNull<R>(R? Function(T) mapper) {
    final completer = Completer<R?>();
    R? result;

    listen(
      (event) {
        final mapped = mapper(event);
        if (mapped != null) {
          result = mapped;
        }
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
