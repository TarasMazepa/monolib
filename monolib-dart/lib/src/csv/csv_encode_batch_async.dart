import 'dart:async';

import 'package:monolib_dart/src/common/encode_batch_async.dart';
import 'package:monolib_dart/src/csv/csv_encode_async.dart';

/// Asynchronously encodes a stream of batches into a CSV format and writes it to a sink.
///
/// This function processes a stream of item [batches], encoding each item as a
/// row in a CSV output. It is useful for handling large datasets in chunks
/// to minimize memory usage.
///
/// The [batches] stream provides lists of elements of type `T`. Each element
/// is expected to be a `List` representing a row, an object that implements
/// a `toCsv()` method returning a `List`, or a `Future` that resolves to one of
/// those.
///
/// You must provide exactly one destination for the output: either an existing
/// [sink], or a [sinkProvider] function that will be called to create a sink
/// when the first data arrives. If [sinkProvider] is used, the created sink
/// will be closed automatically once all batches are processed (if it implements
/// `Sink` or `StreamSink`). If [sink] is provided, it is not closed automatically.
///
/// Example:
/// ```dart
/// final batchesStream = Stream.fromIterable([
///   [['Name', 'Age'], ['Alice', 30]],
///   [['Bob', 25]],
/// ]);
/// final buffer = StringBuffer();
///
/// await csvEncodeBatchAsync(
///   batches: batchesStream,
///   sink: buffer,
/// );
/// print(buffer.toString());
/// // Outputs:
/// // Name,Age
/// // Alice,30
/// // Bob,25
/// ```
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
