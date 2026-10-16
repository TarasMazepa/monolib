library;

import 'package:monolib_dart/monolib_dart.dart';
import 'package:monolib_dart/src/cli/flag_find_result.dart';
import 'package:monolib_dart/src/cli/flag_find_type.dart';
import 'package:monolib_dart/src/cli/optional_flag_result.dart';

/// Represents a command-line flag specification used in CLI parsing architecture.
///
/// The [Flag] class is responsible for defining the structural requirements of a
/// single command-line option (its short name, long name, and description) and
/// providing mutation-based parsing utilities to actively extract the flag and
/// its associated values from a raw list of arguments.
///
/// Rather than returning a static representation of parsed arguments, [Flag]
/// actively modifies the provided argument list by removing the flag token (and
/// potentially its value) once it has been matched. This destructive parsing
/// pattern is intentional: it allows multiple [Flag] definitions or parsers to
/// iteratively process the same argument list, progressively consuming recognized
/// tokens until only positional arguments or unknown flags remain.
///
/// This class handles complex CLI syntactic forms, such as distinguishing
/// standalone short flags (`-v`), combined short flags (`-xv`), and long flags
/// (`--verbose`). It delegates the classification of these matches to
/// [FlagFindResult] and [FlagFindType].
///
/// **Example Usage:**
/// ```dart
/// final args = ['-xv', '--file', 'data.txt'];
/// final verboseFlag = Flag(short: '-v', long: '--verbose', description: 'Enable verbose output');
///
/// if (verboseFlag.hasFlag(args)) {
///   print('Verbose mode enabled!');
///   // args is now: ['-x', '--file', 'data.txt']
/// }
/// ```
class Flag {
  /// The optional single-character short identifier for the flag (e.g., `-v`).
  ///
  /// If provided, it must start with a single hyphen followed by exactly one
  /// character. This allows the flag to be matched individually or as part of a
  /// combined cluster (like `-xvc`).
  final String? short;

  /// The optional long identifier for the flag (e.g., `--verbose`).
  ///
  /// If provided, it must start with double hyphens and have a length greater
  /// than two characters. This identifier is only matched exactly against standalone
  /// tokens in the argument list.
  final String? long;

  /// A human-readable description explaining the purpose of the flag.
  ///
  /// This is typically used when generating automated help text or usage
  /// documentation for a command-line interface.
  final String description;

  /// Constructs a [Flag] specification.
  ///
  /// Either [short] or [long] must be provided (or both). Providing neither
  /// results in an [AssertionError].
  ///
  /// The [short] format must be strictly exactly two characters long, starting
  /// with a hyphen (`-`). The [long] format must start with `--` and be at
  /// least three characters long.
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

  /// Returns the [short] identifier if it exists; otherwise falls back to the [long] identifier.
  ///
  /// Since the constructor guarantees at least one identifier is non-null, this
  /// getter is safely guaranteed to return a valid string.
  String get shortOrLong => (short ?? long)!;

  /// Returns the [long] identifier if it exists; otherwise falls back to the [short] identifier.
  ///
  /// Since the constructor guarantees at least one identifier is non-null, this
  /// getter is safely guaranteed to return a valid string.
  String get longOrShort => (long ?? short)!;

  /// Searches the [args] list for an occurrence of this flag, removes the flag
  /// token from the list if found, and returns a structural match result.
  ///
  /// This is a **mutating** operation. If the flag is matched as a standalone token
  /// (either short or long), that entire token is removed from [args]. If the
  /// flag is matched as part of a grouped cluster of short flags (e.g., matching `-v`
  /// inside `-xv`), only the matched character is removed from that token in the list
  /// (e.g., `-xv` becomes `-x`).
  ///
  /// Returns a [FlagFindResult] detailing the index where the flag was found
  /// and the [FlagFindType] (e.g., [FlagFindType.long], [FlagFindType.shortStandalone],
  /// or [FlagFindType.shortCombined]), which dictates how subsequent values should
  /// be parsed. Returns `null` if the flag is not present.
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

  /// Determines if this flag exists in the provided [args] list, consuming it in the process.
  ///
  /// This is a convenience wrapper around [findAndRemoveFlag] that discards the
  /// detailed match structural data and simply returns a boolean indicating presence.
  ///
  /// **Warning:** This method mutates [args] by removing the matched flag token.
  bool hasFlag(List<String> args) {
    return findAndRemoveFlag(args) != null;
  }

  /// Extracts the required value associated with this flag from the [args] list.
  ///
  /// This method locates the flag, consumes it, and then treats the immediately
  /// subsequent token in the argument list as its value, consuming that as well.
  ///
  /// Returns the extracted string value, or `null` if the flag itself was not
  /// present in the argument list.
  ///
  /// Throws an [Exception] if the flag is present but was found in an invalid
  /// state to accept a value (i.e., a [FlagFindType.shortCombined] cluster), or
  /// if the flag is present at the very end of the list and no subsequent value
  /// token exists to be consumed.
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

  /// Attempts to extract an optional value associated with this flag from the [args] list.
  ///
  /// Unlike [getFlagValue], this method does not throw exceptions if the value
  /// is missing or unparseable. Instead, it returns a sealed [OptionalFlagResult]
  /// type to explicitly communicate the state of the match:
  ///
  /// - Returns [FlagNotPresent] if the flag does not exist in [args].
  /// - Returns [FlagPresent] containing a `null` value if the flag exists but
  ///   was matched in a [FlagFindType.shortCombined] cluster (where explicit values
  ///   are structurally impossible) or if no subsequent token was available.
  /// - Returns [FlagPresent] containing the extracted string value if the flag
  ///   was matched standalone and successfully consumed the next token.
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

  /// Returns a human-readable representation of this flag, combining its identifiers
  /// and description.
  ///
  /// Example output: `-v, --verbose - Enable verbose output`
  @override
  String toString() {
    return "${[short, long].nonNulls.join(", ")} - $description";
  }
}
