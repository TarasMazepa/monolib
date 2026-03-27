import 'jsonl.dart';

extension JsonlOnIterable on Iterable<dynamic> {
  String encodeAsJsonl() => jsonl.encode(toList());
}
