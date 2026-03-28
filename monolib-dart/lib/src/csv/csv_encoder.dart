import 'dart:convert';

class CsvEncoder extends Converter<List<dynamic>, String> {
  const CsvEncoder();

  @override
  String convert(List<dynamic> items) {
    final result = StringBuffer();
    for (final dynamic item_ in items) {
      dynamic item = item_;
      if (item is! List) {
        item = item.toCsv();
        if (item is! List) {
          throw Exception(
            'Expecting $item to be a List or have toCsv() function that returns List',
          );
        }
      }
      for (int i = 0; i < item.length; i++) {
        dynamic cell = item[i];
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
              '\n' when previous == '\r' => true,
              _ => false,
            };
            previous = current;
          }
          if (needsEscaping) {
            result.write('"');
            for (int i = 0; i < cell.length; i++) {
              result.write(switch (cell[i]) {
                '"' => '""',
                final symbol => symbol,
              });
            }
            result.write('"');
          } else {
            result.write(cell);
          }
        }
        if (i == item.length - 1) {
          result.write('\r\n');
        } else {
          result.write(',');
        }
      }
    }
    return result.toString();
  }
}
