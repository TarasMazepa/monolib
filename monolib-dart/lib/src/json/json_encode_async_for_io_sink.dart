import 'dart:io';

import 'json_encode_async.dart';

Future<void> Function(IOSink) jsonEncodeAsyncForIOSink(Object? data) {
  return (IOSink ioSink) => jsonEncodeAsync(data, ioSink);
}
