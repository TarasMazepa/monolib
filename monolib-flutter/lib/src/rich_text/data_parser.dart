import 'package:flutter/widgets.dart';
import 'zalgo_model.dart';

class DataParser {
  static const String objectReplacementCharacter = '\uFFFC';

  /// Parses the raw data string, replacing Zalgo-encoded widgets with
  /// the Object Replacement Character so the TextPainter leaves space.
  static String parseToRenderString(String dataString) {
    String renderString = '';

    // We use characters to iterate over grapheme clusters.
    // However, string concatenation in dart iterating over `.characters`
    // can result in weirdly separated codepoints if we just append them.
    for (final char in dataString.characters) {
      if (ZalgoModel.isWidget(char)) {
        renderString += objectReplacementCharacter;
      } else {
        renderString += char;
      }
    }

    return renderString;
  }
}
