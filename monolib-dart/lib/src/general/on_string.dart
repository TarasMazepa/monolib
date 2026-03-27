extension OnString on String {
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
