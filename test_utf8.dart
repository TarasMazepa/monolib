import 'dart:convert';
import 'dart:typed_data';

extension OnStreamOfListOfInt on Stream<List<int>> {
  Stream<String> utf8DecodeAndLineSplit() {
    return cast<List<int>>().transform(utf8.decoder).transform(const LineSplitter());
  }
}

void main() async {
  Stream<Uint8List> s = Stream.fromIterable([Uint8List.fromList([104, 101, 108, 108, 111])]);
  await s.utf8DecodeAndLineSplit().forEach(print);
}
