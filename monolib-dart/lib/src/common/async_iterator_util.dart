import 'dart:async';

Future<void> iterateStreamOrIterable(
    Object items, Future<void> Function(dynamic) processItem) async {
  switch (items) {
    case Stream stream:
      await for (final item in stream) {
        await processItem(item);
      }
      break;

    case Iterable iterable:
      for (final item in iterable) {
        await processItem(item);
      }
      break;

    default:
      throw ArgumentError(
        'The "items" parameter must be an Iterable or a Stream.',
      );
  }
}
