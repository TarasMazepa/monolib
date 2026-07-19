import 'dart:async';
import '../json/json_encode_async.dart';

Future<void> jsonlEncodeAsync({
  required Object items,
  StringSink? sink,
  StringSink Function()? sinkProvider,
}) async {
  if ((sink == null) == (sinkProvider == null)) {
    throw ArgumentError(
        'Exactly one of sink or sinkProvider must be provided.');
  }

  StringSink? activeSink = sink;
  bool ownsSink = false;

  StringSink getSink() {
    if (activeSink == null) {
      activeSink = sinkProvider!();
      ownsSink = true;
    }
    return activeSink!;
  }

  try {
    switch (items) {
      case Stream stream:
        await for (final item in stream) {
          await jsonEncodeAsync(object: item, sink: getSink());
          getSink().writeln();
        }

      case Iterable iterable:
        for (final item in iterable) {
          await jsonEncodeAsync(object: item, sink: getSink());
          getSink().writeln();
        }

      default:
        throw ArgumentError(
          'The "items" parameter must be an Iterable or a Stream.',
        );
    }
  } finally {
    if (ownsSink && activeSink != null) {
      if (activeSink is StreamSink) {
        await (activeSink as StreamSink).close();
      } else if (activeSink is Sink) {
        (activeSink as Sink).close();
      }
    }
  }
}
