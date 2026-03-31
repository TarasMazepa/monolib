import 'package:monolib_dart/json_encode_async.dart';

Future<void> jsonlEncodeAsync(Object items, StringSink sink) async {
  switch (items) {
    case Stream stream:
      await for (final item in stream) {
        await jsonEncodeAsync(item, sink);
        sink.writeln();
      }

    case Iterable iterable:
      for (final item in iterable) {
        await jsonEncodeAsync(item, sink);
        sink.writeln();
      }

    default:
      throw ArgumentError(
          'The "items" parameter must be an Iterable or a Stream.');
  }
}
