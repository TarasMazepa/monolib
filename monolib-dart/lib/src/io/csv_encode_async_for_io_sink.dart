import 'dart:io';

import '../../csv.dart';

Future<void> Function(IOSink) csvEncodeAsyncForIOSink(Object items) {
  return (IOSink ioSink) => csvEncodeAsync(items, ioSink);
}
