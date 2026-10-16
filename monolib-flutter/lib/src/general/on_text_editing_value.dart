/// Provides contextual text evaluation utilities for editing states.
library;

import 'package:flutter/widgets.dart';

/// An architectural extension on [TextEditingValue] providing contextual text evaluation.
///
/// This extension resolves the relevant bounds of user input based on the current
/// cursor state. It is primarily used to isolate the active typing context from
/// trailing text, enabling precise pattern matching or text analysis in
/// input-driven workflows without manual boundary calculation.
extension OnTextEditingValue on TextEditingValue {
  /// Resolves the contextual [TextRange] of [text] that should be evaluated
  /// based on the current [selection] state.
  ///
  /// This property determines the relevant text boundaries by evaluating the
  /// cursor position:
  /// * Invalid Selection: Returns the entire length of [text] (e.g., when the field lacks focus).
  /// * Collapsed Selection: Returns the range from `0` to the cursor's [TextSelection.end],
  ///   ignoring trailing text ahead of the cursor to isolate the user's current typing context.
  /// * Active Selection: Returns the highlighted [selection] itself.
  ///
  /// ```dart
  /// final value = TextEditingValue(
  ///   text: 'hello world',
  ///   selection: TextSelection.collapsed(offset: 5),
  /// );
  ///
  /// final contextRange = value.textMatchingContext;
  /// print(contextRange.textInside(value.text)); // 'hello'
  /// ```
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
