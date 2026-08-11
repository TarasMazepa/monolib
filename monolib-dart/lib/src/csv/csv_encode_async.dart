import 'dart:async';

import 'package:monolib_dart/src/common/async_iterator_util.dart';
import 'package:monolib_dart/src/common/with_lazy_string_sink.dart';
import 'package:monolib_dart/src/csv/csv_cell_writer.dart';

Future<void> csvEncodeAsync({
  required Object items,
  StringSink? sink,
  StringSink Function()? sinkProvider,
}) {
  return withLazyStringSink(
    sink: sink,
    sinkProvider: sinkProvider,
    action: (getSink) async {
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
          final activeSink = getSink();
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
