library;

import 'package:monolib_dart/src/cli/flag.dart';
import 'package:monolib_dart/src/cli/flag_find_result.dart';

/// Describes the syntactic format in which a command-line flag was discovered
/// within a list of arguments.
///
/// In the CLI parsing architecture (see [Flag] and [FlagFindResult]), a single
/// flag can be represented in multiple forms (e.g., `--verbose`, `-v`, or
/// combined like `-xv`). Understanding how a flag was found is crucial for
/// correctly extracting subsequent values. For instance, [Flag.getFlagValue]
/// requires a standalone flag to consume the next token as its value, whereas
/// a [shortCombined] flag cannot accept an explicit value in the same manner.
///
/// **Usage Example:**
/// ```dart
/// final flag = Flag(short: '-v', long: '--verbose', description: 'Verbose mode');
/// final result = flag.findAndRemoveFlag(['-xvc']);
///
/// if (result?.type == FlagFindType.shortCombined) {
///   print('Found as a combined short flag!');
/// }
/// ```
enum FlagFindType {
  /// The flag was matched by its long name identifier (e.g., `--help`).
  ///
  /// This typically represents a standalone argument token in the argument list.
  long,

  /// The flag was matched by its short name identifier as an independent token
  /// (e.g., `-h`).
  ///
  /// This implies the argument was not grouped with other short flags and is
  /// free to consume the subsequent argument as its value if needed.
  shortStandalone,

  /// The flag was matched as part of a grouped cluster of short flags
  /// (e.g., `-xv` where `-v` is the flag).
  ///
  /// Flags found in a combined cluster are typically booleans or option flags
  /// without explicit values. Methods like [Flag.getFlagValue] will throw an
  /// exception if invoked on a flag matched in this format.
  shortCombined,
}
