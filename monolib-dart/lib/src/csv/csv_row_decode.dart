List<String> csvRowDecode(String items) {
  final result = <String>[];
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
          result.add(
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
        if (leftIndex == rightIndex &&
            leftIndex > 0 &&
            items[leftIndex - 1] == '"') {
          leftIndex = rightIndex = rightIndex + 1;
        } else {
          result.add(items.substring(leftIndex, rightIndex));
          leftIndex = rightIndex = rightIndex + 1;
        }
      } else if (current == '\r') {
        if (rightIndex < items.length - 1 && items[rightIndex + 1] == '\n') {
          if (leftIndex != rightIndex ||
              (leftIndex > 0 && items[leftIndex - 1] == ',')) {
            result.add(items.substring(leftIndex, rightIndex));
          }
          return result; // Stop at first newline sequence
        } else {
          rightIndex++;
        }
      } else if (current == '\n') {
        if (leftIndex != rightIndex ||
            (leftIndex > 0 && items[leftIndex - 1] == ',')) {
          result.add(items.substring(leftIndex, rightIndex));
        }
        return result; // Stop at first newline sequence
      } else {
        rightIndex++;
      }
    }
  }

  if (items.isNotEmpty &&
      (leftIndex > 0 && items[leftIndex - 1] == ',' ||
          leftIndex != rightIndex)) {
    result.add(items.substring(leftIndex, rightIndex));
  }

  // if empty string was passed, we'll get an empty list instead of [''] which might or might not be correct depending on CsvDecoder's behavior
  return result;
}
