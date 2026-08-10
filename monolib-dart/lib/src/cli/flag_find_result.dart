import 'package:monolib_dart/src/cli/flag.dart';
import 'package:monolib_dart/src/cli/flag_find_type.dart';

class FlagFindResult {
  final int index;
  final FlagFindType type;
  final Flag matchedFlag;

  FlagFindResult(this.index, this.type, this.matchedFlag);
}
