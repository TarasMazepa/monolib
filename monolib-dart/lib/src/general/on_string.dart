import '../csv/csv.dart';

extension OnString on String {
  String removeEndingNewLine() {
    if (isEmpty) return this;
    if (this[length - 1] != '\n') return this;
    return substring(0, length - 1);
  }

  String ensureEndsWithADot() {
    if (isEmpty) return '.';
    if (endsWith('.')) return this;
    return '$this.';
  }

  String removeEnclosingQuotationMarks() {
    if (isEmpty) return this;
    if (startsWith('"') && endsWith('"') && length >= 2) {
      return substring(1, length - 1);
    }
    return this;
  }
}

extension OnNullableString on String? {
  String? emptyToNull() => switch (this) {
        null || '' => null,
        _ => this,
      };
}

extension OnStringCsv on String {
  List<List<String>> decodeCsv() {
    return csv.decode(this).cast<List<String>>();
  }
}
