class ZalgoModel {
  static const String baseChar = 'a';

  /// Encodes a widget ID into a single grapheme cluster using a base character
  /// and a combining character.
  static String encodeWidget(int widgetId) {
    // Using Combining Diacritical Marks (0x0300 - 0x036F) for prototype
    // Assuming widgetId is small enough for the prototype.
    final combiningChar = String.fromCharCode(0x0300 + widgetId);
    return '$baseChar$combiningChar';
  }

  /// Decodes a widget ID from a grapheme cluster, if it represents a widget.
  static int? decodeWidget(String graphemeCluster) {
    if (graphemeCluster.isNotEmpty &&
        graphemeCluster[0] == baseChar &&
        graphemeCluster.length > 1) {
      final codeUnit = graphemeCluster.codeUnitAt(1);
      if (codeUnit >= 0x0300 && codeUnit <= 0x036F) {
        return codeUnit - 0x0300;
      }
    }
    return null;
  }

  /// Checks if a grapheme cluster is a Zalgo encoded widget.
  static bool isWidget(String graphemeCluster) {
    return decodeWidget(graphemeCluster) != null;
  }
}
