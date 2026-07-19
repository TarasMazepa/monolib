import 'dart:io';

import 'json_encode_async.dart';

Future<void> jsonEncodeAsyncForIOSink({
  required Object? data,
  IOSink? ioSink,
  IOSink Function()? ioSinkProvider,
}) {
  return jsonEncodeAsync(
    object: data,
    sink: ioSink,
    sinkProvider: ioSinkProvider,
  );
}
