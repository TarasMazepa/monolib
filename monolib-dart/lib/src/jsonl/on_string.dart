import 'jsonl.dart';

extension JsonlOnString on String {
  List<dynamic> decodeFromJsonl() => jsonl.decode(this);
}
