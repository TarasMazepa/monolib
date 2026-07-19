import 'dart:io';

import 'jsonl_encode_async.dart';

Future<void> jsonlEncodeAsyncForIOSink({
  required Object items,
  IOSink? ioSink,
  IOSink Function()? ioSinkProvider,
}) {
  return jsonlEncodeAsync(
    items: items,
    sink: ioSink,
    sinkProvider: ioSinkProvider,
  );
}
