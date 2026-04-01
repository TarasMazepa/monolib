import 'dart:convert';

extension OnStreamOfListOfInt on Stream<List<int>> {
  /// Decodes the stream as UTF-8 and splits it into lines.
  Stream<String> utf8DecodeAndLineSplit() {
    return transform(utf8.decoder).transform(const LineSplitter());
  }
}
