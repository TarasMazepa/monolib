import 'package:flutter/widgets.dart';

extension OnTextEditingValue on TextEditingValue {
  TextRange get textMatchingContext {
    if (!selection.isValid) {
      return TextRange(start: 0, end: text.length);
    }
    if (selection.isCollapsed) {
      return TextRange(start: 0, end: selection.end);
    }
    return selection;
  }
}
