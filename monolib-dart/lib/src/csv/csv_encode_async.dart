import 'dart:async';

import '../common/async_iterator_util.dart';
import 'csv_cell_writer.dart';

Future<void> csvEncodeAsync(Object items, StringSink sink) async {
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
      writeCsvCell(cell, sink);
      if (i == item.length - 1) {
        sink.write('\r\n');
      } else {
        sink.write(',');
      }
    }
  }

  await iterateStreamOrIterable(items, writeRow);
}
