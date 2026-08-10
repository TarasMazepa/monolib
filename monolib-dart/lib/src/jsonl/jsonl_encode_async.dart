import 'dart:async';

import '../common/async_iterator_util.dart';
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

  bool ownsSink = false;
  late StringSink activeSink = sink ??
      () {
        ownsSink = true;
        return sinkProvider!();
      }();

  try {
    await iterateStreamOrIterable(items, (item) async {
      try {
        await jsonEncodeAsync(object: item, sink: activeSink);
      } finally {
        activeSink.writeln();
      }
    });
  } finally {
    if (ownsSink) {
      if (activeSink is StreamSink) {
        await (activeSink as StreamSink).close();
      } else if (activeSink is Sink) {
        (activeSink as Sink).close();
      }
    }
  }
}
