import 'dart:async';

import 'package:monolib_dart/src/common/encode_batch_async.dart';
import 'package:monolib_dart/src/jsonl/jsonl_encode_async.dart';

Future<void> jsonlEncodeBatchAsync<T>({
  required Stream<List<T>> batches,
  StringSink? sink,
  StringSink Function()? sinkProvider,
}) {
  return encodeBatchAsync(
    batches: batches,
    encodeAsync: (items, sink) => jsonlEncodeAsync(items: items, sink: sink),
    sink: sink,
    sinkProvider: sinkProvider,
  );
}
