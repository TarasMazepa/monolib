import 'dart:io';

import 'jsonl_encode_async.dart';

Future<void> Function(IOSink) jsonlEncodeAsyncForIOSink(Object items) {
  return (IOSink ioSink) => jsonlEncodeAsync(items, ioSink);
}
