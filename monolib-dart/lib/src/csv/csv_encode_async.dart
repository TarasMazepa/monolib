/// Asynchronous CSV encoding operations for both streaming and synchronous collections.
library;

import 'dart:async';

import 'package:monolib_dart/src/common/async_iterator_util.dart';
import 'package:monolib_dart/src/common/with_lazy_string_sink.dart';
import 'package:monolib_dart/src/csv/csv_cell_writer.dart';

/// Asynchronously encodes a sequence of items into an RFC 4180 CSV format and writes them
/// to a string sink.
///
/// This function acts as the foundational CSV encoder within the repository's
/// data parsing architecture. It unifies the processing of heterogeneous
/// collections by accepting both `Stream` and `Iterable` inputs through the
/// [items] parameter, relying on [iterateStreamOrIterable] to handle the
/// asynchronous traversal.
///
/// The encoder dynamically resolves `Future` values, meaning that the `items`
/// collection can contain futures resolving to rows, and the individual rows
/// can contain futures resolving to cell values. Each row element is expected
/// to either be a `List`, or an object that implements a `toCsv()` method
/// returning a `List`.
///
/// To protect against zero-byte files when a stream yields no data, this
/// function delegates manual [StringSink] initialization and resource management
/// to [withLazyStringSink].
///
/// You must provide exactly one destination for the output: either an existing
/// [sink], or a [sinkProvider] function that will be called to create a sink
/// on the first piece of incoming data. If [sinkProvider] is used, the created
/// sink will be closed automatically upon completion or error (if it implements
/// `Sink` or `StreamSink`). If [sink] is provided, it is not automatically closed.
///
/// Throws an [ArgumentError] if both [sink] and [sinkProvider] are provided,
/// or if neither is provided. Throws an [Exception] if an item in the collection
/// is not a `List` and lacks a valid `toCsv()` method.
///
/// Example:
/// ```dart
/// final buffer = StringBuffer();
/// final stream = Stream.fromIterable([
///   ['Alice', 30],
///   ['Bob', 25],
///   Future.value(['Charlie', 40]), // dynamically resolves futures
/// ]);
///
/// await csvEncodeAsync(
///   items: stream,
///   sink: buffer,
/// );
/// print(buffer.toString());
/// // Outputs:
/// // Alice,30
/// // Bob,25
/// // Charlie,40
/// ```
Future<void> csvEncodeAsync({
  required Object items,
  StringSink? sink,
  StringSink Function()? sinkProvider,
}) {
  return withLazyStringSink(
    sink: sink,
    sinkProvider: sinkProvider,
    action: (getSink) async {
      late final activeSink = getSink();
      Future<void> writeRow(dynamic item_) async {
        dynamic item = item_;
        if (item is Future) {
          item = await item;
        }
        if (item is! List) {
          try {
            item = (item as dynamic).toCsv();
            if (item is Future) {
              item = await item;
            }
          } on NoSuchMethodError {
            // ignore
          } catch (e) {
            rethrow;
          }
          if (item is! List) {
            throw Exception(
              'Expecting $item to be a List or have toCsv() function that returns List',
            );
          }
        }
        for (int i = 0; i < item.length; i++) {
          dynamic cell = item[i];
          if (cell is Future) {
            cell = await cell;
          }
          if (cell is! String) {
            cell = '$cell';
          }
          writeCsvCell(cell, activeSink);
          if (i == item.length - 1) {
            activeSink.write('\r\n');
          } else {
            activeSink.write(',');
          }
        }
      }

      await iterateStreamOrIterable(items, writeRow);
    },
  );
}
