import 'package:flutter/widgets.dart';
import 'zalgo_model.dart';

class ExitNodes {
  /// A stub for converting the raw data string to Markdown.
  static String toMarkdown(String dataString) {
    String markdown = '';
    for (final char in dataString.characters) {
      if (ZalgoModel.isWidget(char)) {
        final widgetId = ZalgoModel.decodeWidget(char);
        markdown += '[Widget $widgetId]';
      } else {
        markdown += char;
      }
    }
    return markdown;
  }

  /// A stub for converting Markdown back to the raw data string.
  static String fromMarkdown(String markdown) {
    // Very basic and naive implementation for prototype purposes
    String dataString = markdown;
    // Assume widget IDs are 0-9 for simplicity in this prototype stub
    for (int i = 0; i < 10; i++) {
      dataString =
          dataString.replaceAll('[Widget $i]', ZalgoModel.encodeWidget(i));
    }
    return dataString;
  }
}
