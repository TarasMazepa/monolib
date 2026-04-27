import '../../monolib_dart.dart';
import 'flag_find_result.dart';
import 'flag_find_type.dart';
import 'optional_flag_result.dart';

class Flag {
  final String? short;
  final String? long;
  final String description;

  Flag({this.short, this.long, required this.description})
      : assert(
          short != null || long != null,
          'Either short or long should be not null',
        ),
        assert(
          short == null || (short.startsWith('-') && short.length == 2),
          "Short should have format '-x', where x is a single symbol",
        ),
        assert(
          long == null || (long.startsWith('--') && long.length > 2),
          "Long should have format '--xxx', where xxx is a long name of the flag",
        );

  String get shortOrLong => (short ?? long)!;

  FlagFindResult? findAndRemoveFlag(List<String> args) {
    if (long case final longFlag?) {
      final index = args.indexOf(longFlag).asNullableIndex;
      if (index != null) {
        args.removeAt(index);
        return FlagFindResult(index, FlagFindType.long, this);
      }
    }

    if (short case final shortFlag?) {
      final index = args.indexOf(shortFlag).asNullableIndex;
      if (index != null) {
        args.removeAt(index);
        return FlagFindResult(index, FlagFindType.shortStandalone, this);
      }

      for (int i = 0; i < args.length; i++) {
        final arg = args[i];
        if (arg.length < 2) continue;
        if (arg[0] != '-') continue;
        if (arg[1] == '-') continue;
        final newArg = arg.replaceFirst(shortFlag[1], '');
        if (newArg.length < arg.length) {
          if (newArg == '-') {
            args.removeAt(i);
            return FlagFindResult(i, FlagFindType.shortStandalone, this);
          } else {
            args[i] = newArg;
            return FlagFindResult(i, FlagFindType.shortCombined, this);
          }
        }
      }
    }

    return null;
  }

  bool hasFlag(List<String> args) {
    return findAndRemoveFlag(args) != null;
  }

  String? getFlagValue(List<String> args) {
    final findResult = findAndRemoveFlag(args);
    if (findResult != null) {
      if (findResult.type == FlagFindType.shortCombined) {
        throw Exception(
          "Value wasn't provided for '${findResult.matchedFlag}'.",
        );
      }

      final index = findResult.index;
      if (args.length <= index) {
        throw Exception(
          "Value wasn't provided for '${findResult.matchedFlag}'.",
        );
      }
      final value = args[index];
      args.removeAt(index);
      return value;
    }

    return null;
  }

  OptionalFlagResult getOptionalFlagValue(List<String> args) {
    final findResult = findAndRemoveFlag(args);
    if (findResult == null) {
      return FlagNotPresent();
    }

    if (findResult.type == FlagFindType.shortCombined) {
      return FlagPresent(null);
    }

    final index = findResult.index;
    if (args.length > index) {
      final nextArg = args[index];
      args.removeAt(index);
      return FlagPresent(nextArg);
    }

    return FlagPresent(null);
  }

  @override
  String toString() {
    return "${[short, long].nonNulls.join(", ")} - $description";
  }
}
