import 'dart:convert';
import 'csv_row_decode.dart';

class CsvDecoder extends Converter<String, List<List<String>>> {
  const CsvDecoder();

  @override
  List<List<String>> convert(String items) {
    if (items.isEmpty) return [];

    final result = <List<String>>[];
    int leftIndex = 0;
    int rightIndex = 0;
    bool isInsideDoubleQuotes = false;

    while (rightIndex < items.length) {
      final current = items[rightIndex];

      if (isInsideDoubleQuotes) {
        if (current == '"') {
          if (rightIndex < items.length - 1 && items[rightIndex + 1] == '"') {
            rightIndex += 2;
          } else {
            isInsideDoubleQuotes = false;
            rightIndex++;
          }
        } else {
          rightIndex++;
        }
      } else {
        if (current == '"') {
          isInsideDoubleQuotes = true;
          rightIndex++;
        } else if (current == '\r') {
          if (rightIndex < items.length - 1 && items[rightIndex + 1] == '\n') {
            result.add(csvRowDecode(items.substring(leftIndex, rightIndex)));
            leftIndex = rightIndex = rightIndex + 2;
          } else {
            rightIndex++;
          }
        } else if (current == '\n') {
          result.add(csvRowDecode(items.substring(leftIndex, rightIndex)));
          leftIndex = rightIndex = rightIndex + 1;
        } else {
          rightIndex++;
        }
      }
    }

    if (leftIndex != rightIndex ||
        (leftIndex > 0 && items[leftIndex - 1] != '\n')) {
      result.add(csvRowDecode(items.substring(leftIndex, rightIndex)));
    }

    return result;
  }
}
