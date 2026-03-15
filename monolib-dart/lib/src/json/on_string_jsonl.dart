import 'jsonl.dart';

extension JsonlOnString on String {
  List decodeFromJsonl() => jsonl.decode(this);
}
