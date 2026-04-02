import 'dart:convert';

extension OnStreamOfListOfInt on Stream<List<int>> {
  Future<String> readLine() {
    return cast<List<int>>()
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .first;
  }
}
