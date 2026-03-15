import 'jsonl.dart';

extension JsonlOnIterable on Iterable {
  String encodeAsJsonl() => jsonl.encode(toList());
}
