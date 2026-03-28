import 'dart:math';

import 'on_list.dart';
import 'table_cell_align_right.dart';

extension OnListOfLists on List<List> {
  void formatTable(StringSink sink) {
    final maxWidths = List.filled(
      fold(0, (maxSize, item) => max(maxSize, item.length)),
      0,
    );
    final strings = toMappedList(
      (list) => list
          .map(
            (x) => switch (x) {
              null => '',
              _ => x.toString(),
            },
          )
          .toList(),
    );
    for (final list in strings) {
      for (int i = 0; i < list.length; i++) {
        maxWidths[i] = max(maxWidths[i], list[i].length);
      }
    }
    for (int l = 0; l < strings.length; l++) {
      final list = strings[l];
      for (int i = 0; i < list.length; i++) {
        final cell = this[l][i];
        if (cell is num || cell is TableCellAlignRight) {
          sink.write(list[i].padLeft(maxWidths[i]));
        } else {
          sink.write(list[i].padRight(maxWidths[i]));
        }
        if (i < list.length - 1 && maxWidths[i] > 0) {
          sink.write(' ');
        }
      }
      sink.write('\n');
    }
  }
}
