import 'dart:convert';

import 'package:monolib_dart/src/csv/csv_cell_writer.dart';

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
        writeCsvCell(cell, result);
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
