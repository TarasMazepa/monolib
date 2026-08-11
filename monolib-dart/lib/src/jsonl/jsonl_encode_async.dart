import 'dart:async';

import 'package:monolib_dart/src/common/async_iterator_util.dart';
import 'package:monolib_dart/src/common/with_lazy_string_sink.dart';
import 'package:monolib_dart/src/json/json_encode_async.dart';

Future<void> jsonlEncodeAsync({
  required Object items,
  StringSink? sink,
  StringSink Function()? sinkProvider,
}) {
  return withLazyStringSink(
    sink: sink,
    sinkProvider: sinkProvider,
    action: (getSink) async {
      await iterateStreamOrIterable(items, (item) async {
        final activeSink = getSink();
        try {
          await jsonEncodeAsync(object: item, sink: activeSink);
        } finally {
          activeSink.writeln();
        }
      });
    },
  );
}
