import 'dart:async';

import 'package:monolib_dart/src/common/async_iterator_util.dart';
import 'package:monolib_dart/src/common/with_lazy_string_sink.dart';

Future<void> encodeBatchAsync<T>({
  required Stream<List<T>> batches,
  required Future<void> Function(Object items, StringSink sink) encodeAsync,
  StringSink? sink,
  StringSink Function()? sinkProvider,
}) {
  return withLazyStringSink(
    sink: sink,
    sinkProvider: sinkProvider,
    action: (getSink) async {
      await iterateStreamOrIterable(batches, (dynamic batch) async {
        await encodeAsync(batch as Object, getSink());
      });
    },
  );
}
