import 'dart:convert';

class CsvDecoder extends Converter<String, List<List<String>>> {
  const CsvDecoder();

  @override
  List<List<String>> convert(String items) {
    final result = <List<String>>[[]];
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
            result.last.add(
              items.substring(leftIndex, rightIndex).replaceAll('""', '"'),
            );
            leftIndex = rightIndex = rightIndex + 1;
          }
        } else {
          rightIndex++;
        }
      } else {
        if (leftIndex == rightIndex && current == '"') {
          isInsideDoubleQuotes = true;
          leftIndex++;
          rightIndex++;
        } else if (current == ',') {
          if (leftIndex == rightIndex && items[rightIndex - 1] == '"') {
            leftIndex = rightIndex = rightIndex + 1;
          } else {
            result.last.add(items.substring(leftIndex, rightIndex));
            leftIndex = rightIndex = rightIndex + 1;
          }
        } else if (current == '\r') {
          if (rightIndex < items.length - 1 && items[rightIndex + 1] == '\n') {
            if (leftIndex != rightIndex || items[rightIndex - 1] == ',') {
              result.last.add(items.substring(leftIndex, rightIndex));
            }
            result.add([]);
            leftIndex = rightIndex = rightIndex + 2;
          } else {
            rightIndex++;
          }
        } else if (current == '\n') {
          if (leftIndex != rightIndex || items[rightIndex - 1] == ',') {
            result.last.add(items.substring(leftIndex, rightIndex));
          }
          result.add([]);
          leftIndex = rightIndex = rightIndex + 1;
        } else {
          rightIndex++;
        }
      }
    }
    if (items.isNotEmpty &&
        (leftIndex > 0 && items[leftIndex - 1] == ',' ||
            leftIndex != rightIndex)) {
      result.last.add(items.substring(leftIndex, rightIndex));
    }
    if (result.last.isEmpty) {
      result.removeLast();
    }
    return result;
  }
}
