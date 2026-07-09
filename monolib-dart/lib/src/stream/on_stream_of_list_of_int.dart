import 'dart:convert';

extension OnStreamOfListOfInt on Stream<List<int>> {
  Future<String> readLine() {
    return transform(utf8.decoder).transform(const LineSplitter()).first;
  }

  Stream<String> utf8DecodeAndLineSplit() {
    return transform(utf8.decoder).transform(const LineSplitter());
  }
}
