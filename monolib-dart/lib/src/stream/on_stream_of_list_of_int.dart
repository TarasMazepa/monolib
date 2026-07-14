import 'dart:convert';

import 'line_splitter_converter.dart';

extension OnStreamOfListOfInt on Stream<List<int>> {
  Future<String> readLine() {
    return cast<List<int>>()
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .first;
  }

  Stream<String> utf8DecodeAndLineSplit() {
    return cast<List<int>>()
        .transform(utf8.decoder.fuse(const LineSplitterConverter()));
  }
}
