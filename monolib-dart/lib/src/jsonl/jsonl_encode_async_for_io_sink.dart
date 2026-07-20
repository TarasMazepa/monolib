import 'dart:io';

import 'jsonl_encode_async.dart';

Future<void> Function(IOSink) jsonlEncodeAsyncForIOSink(Object items) {
  return (IOSink ioSink) => jsonlEncodeAsync(items: items, sink: ioSink);
}

Future<void> Function(IOSink Function()) jsonlEncodeAsyncForIOSinkProvider({
  required Object items,
}) {
  return (IOSink Function() ioSinkProvider) =>
      jsonlEncodeAsync(items: items, sinkProvider: ioSinkProvider);
}
