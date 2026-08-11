import 'dart:async';

import 'package:monolib_dart/src/common/async_iterator_util.dart';
import 'package:monolib_dart/src/csv/csv_encode_async.dart';

Future<void> csvEncodeBatchAsync<T>({
  required Stream<List<T>> batches,
  StringSink? sink,
  StringSink Function()? sinkProvider,
}) async {
  if ((sink == null) == (sinkProvider == null)) {
    throw ArgumentError(
      'Exactly one of sink or sinkProvider must be provided.',
    );
  }

  bool ownsSink = false;
  late StringSink activeSink = sink ??
      () {
        ownsSink = true;
        return sinkProvider!();
      }();

  try {
    await iterateStreamOrIterable(batches, (dynamic batch) async {
      await csvEncodeAsync(items: batch as Object, sink: activeSink);
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
