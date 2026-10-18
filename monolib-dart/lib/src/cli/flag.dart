import 'package:monolib_dart/monolib_dart.dart';
import 'package:monolib_dart/src/cli/flag_find_result.dart';
import 'package:monolib_dart/src/cli/flag_find_type.dart';
import 'package:monolib_dart/src/cli/optional_flag_result.dart';

/// A command-line flag specification with mutating argument-parsing utilities.
///
/// Defines a command-line option by its [short] name, [long] name, and
/// [description], and provides methods to extract the flag and its associated
/// value from a mutable list of raw CLI arguments.
///
/// When a flag is matched, its token (and optional value) is removed in place
/// from the argument list so that multiple [Flag] definitions can iteratively
/// consume recognized options until only positional arguments or unknown flags
/// remain.
///
/// Supports standalone short flags (`-v`), combined short flag clusters
/// (`-xv`), and long flags (`--verbose`), classifying matches via
/// [FlagFindResult] and [FlagFindType].
///
/// Example:
/// ```dart
/// final args = ['-xv', '--file', 'data.txt'];
/// final verboseFlag = Flag(
///   short: '-v',
///   long: '--verbose',
///   description: 'Enable verbose output',
/// );
///
/// if (verboseFlag.hasFlag(args)) {
///   print('Verbose mode enabled!');
///   // args is now: ['-x', '--file', 'data.txt']
/// }
/// ```
class Flag {
  /// The optional single-character short identifier for the flag (e.g., `-v`).
  ///
  /// If provided, it must start with a single hyphen followed by a single
  /// character. It can be matched as a standalone token or within a combined
  /// short-flag cluster (such as `-xvc`).
  final String? short;

  /// The optional long identifier for the flag (e.g., `--verbose`).
  ///
  /// If provided, it must start with `--` and be at least three characters
  /// long. It is matched only against standalone tokens in the argument list.
  final String? long;

  /// A human-readable description explaining the purpose of the flag.
  final String description;

  /// Creates a [Flag] specification.
  ///
  /// At least one of [short] or [long] must be non-null.
  ///
  /// If provided, [short] must be two characters starting with `-`, and [long]
  /// must be at least three characters starting with `--`.
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

  /// Returns the [short] identifier if non-null, or the [long] identifier
  /// otherwise.
  String get shortOrLong => (short ?? long)!;

  /// Returns the [long] identifier if non-null, or the [short] identifier
  /// otherwise.
  String get longOrShort => (long ?? short)!;

  /// Searches [args] for this flag, removes the matched flag from [args], and
  /// returns a [FlagFindResult] describing the match.
  ///
  /// If matched as a standalone token (either [short] or [long]), the entire
  /// token is removed from [args]. If matched within a combined cluster of
  /// short flags (e.g., `-v` inside `-xv`), only the matched character is
  /// removed from that token (leaving `-x`).
  ///
  /// Returns `null` if the flag is not present in [args].
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

  /// Returns `true` if this flag is present in [args], removing it in the
  /// process.
  ///
  /// Convenience wrapper around [findAndRemoveFlag] that discards the match
  /// details.
  bool hasFlag(List<String> args) {
    return findAndRemoveFlag(args) != null;
  }

  /// Extracts and removes both this flag and its required value from [args].
  ///
  /// Returns the consumed value token that immediately followed the flag, or
  /// `null` if the flag was not present in [args].
  ///
  /// Throws an [Exception] if the flag was matched in a
  /// [FlagFindType.shortCombined] cluster or if no value token follows the
  /// flag at the end of [args].
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

  /// Extracts and removes this flag and its optional value from [args].
  ///
  /// Unlike [getFlagValue], this method does not throw when no value follows
  /// the flag:
  /// - Returns [FlagNotPresent] if the flag does not exist in [args].
  /// - Returns [FlagPresent] with a `null` value if the flag was matched in a
  ///   [FlagFindType.shortCombined] cluster or at the end of [args].
  /// - Returns [FlagPresent] with the extracted [String] value if the flag was
  ///   matched standalone and consumed the following token.
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

  /// Returns a formatted string combining the flag's identifiers and
  /// [description] (e.g., `-v, --verbose - Enable verbose output`).
  @override
  String toString() {
    return "${[short, long].nonNulls.join(", ")} - $description";
  }
}
