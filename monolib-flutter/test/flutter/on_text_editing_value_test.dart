import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monolib_flutter/monolib_flutter.dart';

void main() {
  test('textMatchingContext returns full text when selection is invalid', () {
    const value = TextEditingValue(
      text: 'hello',
      selection: TextSelection.collapsed(offset: -1),
    );
    expect(value.textMatchingContext, const TextRange(start: 0, end: 5));
  });

  test('textMatchingContext returns prefix when selection is collapsed', () {
    const value = TextEditingValue(
      text: 'hello',
      selection: TextSelection.collapsed(offset: 2),
    );
    expect(value.textMatchingContext, const TextRange(start: 0, end: 2));
  });

  test('textMatchingContext returns selection when valid and uncollapsed', () {
    const value = TextEditingValue(
      text: 'hello',
      selection: TextSelection(baseOffset: 1, extentOffset: 4),
    );
    expect(value.textMatchingContext, const TextRange(start: 1, end: 4));
  });
}
