import 'dart:io';

import '../../jsonl.dart';

Future<void> Function(IOSink) jsonlEncodeAsyncForIOSink(Object items) {
  return (IOSink ioSink) => jsonlEncodeAsync(items, ioSink);
}
