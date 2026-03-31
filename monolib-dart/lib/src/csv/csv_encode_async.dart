import 'dart:async';

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
      if (cell.isEmpty) {
        // do nothing
      } else {
        int index = 0;
        bool needsEscaping = cell[0] == '"';
        String? previous;
        while (!needsEscaping && index < cell.length) {
          final current = cell[index++];
          needsEscaping = switch (current) {
            ',' => true,
            '\r' => false,
            '\n' => true,
            '"' => true,
            _ => false,
          };
          previous = current;
        }
        if (needsEscaping) {
          sink.write('"');
          for (int j = 0; j < cell.length; j++) {
            sink.write(switch (cell[j]) {
              '"' => '""',
              final symbol => symbol,
            });
          }
          sink.write('"');
        } else {
          sink.write(cell);
        }
      }
      if (i == item.length - 1) {
        sink.write('\r\n');
      } else {
        sink.write(',');
      }
    }
  }

  switch (items) {
    case Stream stream:
      await for (final item in stream) {
        await writeRow(item);
      }

    case Iterable iterable:
      for (final item in iterable) {
        await writeRow(item);
      }

    default:
      throw ArgumentError(
          'The "items" parameter must be an Iterable or a Stream.');
  }
}
