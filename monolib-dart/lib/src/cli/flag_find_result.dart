import 'package:monolib_dart/src/cli/flag.dart';
import 'package:monolib_dart/src/cli/flag_find_type.dart';

/// The result of locating and removing a [Flag] from an argument list.
///
/// Returned by [Flag.findAndRemoveFlag] after stripping the matched flag token
/// from the argument list. Retains the match [index], syntax [type], and
/// originating [matchedFlag] so callers like [Flag.getFlagValue] and
/// [Flag.getOptionalFlagValue] can determine whether a subsequent value token
/// may be consumed.
///
/// Example:
/// ```dart
/// final flag = Flag(short: '-o', long: '--output', description: 'Output file');
/// final args = ['-v', '-o', 'report.txt'];
///
/// final result = flag.findAndRemoveFlag(args);
/// if (result != null) {
///   print('Flag found at index ${result.index}');
///   // args is now: ['-v', 'report.txt']
/// }
/// ```
class FlagFindResult {
  /// The index in the mutated argument list where the flag was found.
  ///
  /// For standalone flags ([FlagFindType.long] or
  /// [FlagFindType.shortStandalone]), this index points to the argument
  /// immediately following the removed flag token.
  final int index;

  /// The syntactic format in which the flag was matched.
  final FlagFindType type;

  /// The [Flag] instance that matched the argument token.
  final Flag matchedFlag;

  /// Creates a [FlagFindResult] with the match [index], syntax [type], and
  /// [matchedFlag].
  FlagFindResult(this.index, this.type, this.matchedFlag);
}
