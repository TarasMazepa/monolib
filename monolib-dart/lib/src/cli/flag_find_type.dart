import 'package:monolib_dart/src/cli/flag.dart';
import 'package:monolib_dart/src/cli/flag_find_result.dart';

/// The syntactic format in which a [Flag] was matched in an argument list.
///
/// Used by [FlagFindResult] to distinguish between standalone flags (`--verbose`
/// or `-v`), which can consume the next token as a value, and combined short
/// flags (`-xv`), which cannot.
///
/// Example:
/// ```dart
/// final flag = Flag(short: '-v', long: '--verbose', description: 'Verbose mode');
/// final result = flag.findAndRemoveFlag(['-xvc']);
///
/// if (result?.type == FlagFindType.shortCombined) {
///   print('Found as a combined short flag!');
/// }
/// ```
enum FlagFindType {
  /// Matched by its long identifier as a standalone token (e.g., `--help`).
  long,

  /// Matched by its short identifier as a standalone token (e.g., `-h`).
  shortStandalone,

  /// Matched as part of a combined cluster of short flags (e.g., `-v` inside
  /// `-xv`).
  ///
  /// Flags matched in a combined cluster cannot take a subsequent value token
  /// via [Flag.getFlagValue].
  shortCombined,
}
