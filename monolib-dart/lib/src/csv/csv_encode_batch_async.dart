import 'dart:async';

import 'package:monolib_dart/src/common/encode_batch_async.dart';
import 'package:monolib_dart/src/csv/csv_encode_async.dart';

Future<void> csvEncodeBatchAsync<T>({
  required Stream<List<T>> batches,
  StringSink? sink,
  StringSink Function()? sinkProvider,
}) {
  return encodeBatchAsync(
    batches: batches,
    encodeAsync: (items, sink) => csvEncodeAsync(items: items, sink: sink),
    sink: sink,
    sinkProvider: sinkProvider,
  );
}
