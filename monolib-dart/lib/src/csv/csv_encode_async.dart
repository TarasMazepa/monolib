import 'dart:async';

import 'package:monolib_dart/src/common/async_iterator_util.dart';
import 'package:monolib_dart/src/common/with_lazy_string_sink.dart';
import 'package:monolib_dart/src/csv/csv_cell_writer.dart';

/// Asynchronously encodes a sequence of [items] into RFC 4180 CSV format and
/// writes each row to a destination [StringSink].
///
/// Accepts both [Iterable] and [Stream] collections via [iterateStreamOrIterable]
/// and dynamically resolves [Future] values at the row, `toCsv()`, and cell
/// levels. Each row is formatted as comma-separated cells escaped with
/// [writeCsvCell] and terminated by `\r\n`.
///
/// Sink initialization and lifecycle management are delegated to
/// [withLazyStringSink]. Exactly one of [sink] or [sinkProvider] must be
/// provided, or an [ArgumentError] is thrown.
///
/// - [items]: The [Iterable] or [Stream] of rows to encode. Each item (or
///   awaited [Future]) must be a [List] of cells or an object implementing a
///   `toCsv()` method that returns a [List] (or `Future<List>`), otherwise an
///   [Exception] is thrown.
/// - [sink]: An active, externally managed [StringSink]. If provided, the
///   caller retains ownership and is responsible for closing it.
/// - [sinkProvider]: A factory callback that lazily creates a [StringSink] when
///   the first row is ready to be written (preventing empty files when [items]
///   yields no elements). The created sink is closed automatically upon
///   completion or error if it implements [Sink] or [StreamSink].
///
/// Example:
/// ```dart
/// final buffer = StringBuffer();
/// final stream = Stream.fromIterable([
///   ['Alice', 30],
///   ['Bob', 25],
///   Future.value(['Charlie', 40]),
/// ]);
///
/// await csvEncodeAsync(
///   items: stream,
///   sink: buffer,
/// );
/// print(buffer.toString());
/// // Result: 'Alice,30\r\nBob,25\r\nCharlie,40\r\n'
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
