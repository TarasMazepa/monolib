class IndexOffsetMapping {
  /// Translates a UTF-16 render string offset back to a raw Data String offset.
  /// This is a stub for the prototype. In reality, it would account for
  /// length differences between Zalgo encoding and the single \uFFFC character.
  static int renderToDataOffset(
      String dataString, String renderString, int renderOffset) {
    // Basic 1:1 mapping stub for the prototype.
    return renderOffset;
  }

  /// Translates a Data String offset to a Render String UTF-16 offset.
  /// This is a stub for the prototype.
  static int dataToRenderOffset(
      String dataString, String renderString, int dataOffset) {
    // Basic 1:1 mapping stub for the prototype.
    return dataOffset;
  }
}
