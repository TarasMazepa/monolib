import 'flag.dart';
import 'flag_find_type.dart';

class FlagFindResult {
  final int index;
  final FlagFindType type;
  final Flag matchedFlag;

  FlagFindResult(this.index, this.type, this.matchedFlag);
}
