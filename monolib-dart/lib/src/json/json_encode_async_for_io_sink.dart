import 'dart:io';

import 'json_encode_async.dart';

Future<void> Function(IOSink) jsonEncodeAsyncForIOSink(Object? data) {
  return (IOSink ioSink) => jsonEncodeAsync(object: data, sink: ioSink);
}

Future<void> Function(IOSink Function()) jsonEncodeAsyncForIOSinkProvider({
  required Object? data,
}) {
  return (IOSink Function() ioSinkProvider) =>
      jsonEncodeAsync(object: data, sinkProvider: ioSinkProvider);
}
