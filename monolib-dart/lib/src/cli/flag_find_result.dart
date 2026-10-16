library;

import 'package:monolib_dart/src/cli/flag.dart';
import 'package:monolib_dart/src/cli/flag_find_type.dart';

/// An intermediate DTO representing the outcome of a successful command-line flag discovery.
///
/// In this repository's destructive CLI parsing architecture, [FlagFindResult]
/// bridges the gap between searching for a flag and subsequently extracting its value.
/// When [Flag.findAndRemoveFlag] matches a token, it mutates the raw argument list
/// by stripping the matched flag and returns this result.
///
/// This object retains the structural context of the discovery ([type]), which is critical
/// for downstream methods like [Flag.getFlagValue] or [Flag.getOptionalFlagValue]. For example,
/// a standalone flag ([FlagFindType.shortStandalone]) indicates that the argument at [index]
/// should now be consumed as the flag's explicit value, whereas a grouped flag
/// ([FlagFindType.shortCombined]) indicates that no explicit value can be consumed.
///
/// **Usage Example:**
/// ```dart
/// final flag = Flag(short: '-o', long: '--output', description: 'Output file');
/// final args = ['-v', '-o', 'report.txt'];
///
/// final result = flag.findAndRemoveFlag(args);
/// if (result != null) {
///   print('Flag found at index ${result.index}');
///   // The arguments list is already mutated: ['-v', 'report.txt']
/// }
/// ```
class FlagFindResult {
  /// The index in the original or partially mutated argument list where the flag
  /// (or its remaining value) was located after discovery.
  ///
  /// For standalone flags, this index currently points to the subsequent argument
  /// which represents the flag's provided value.
  final int index;

  /// The syntactic format in which the flag was discovered.
  ///
  /// This determines the appropriate extraction strategy. For example, if [type] is
  /// [FlagFindType.shortCombined], downstream parsers will throw an exception rather
  /// than incorrectly consuming the next token as a value.
  final FlagFindType type;

  /// The specific [Flag] instance that successfully matched the token.
  ///
  /// This allows consumers to identify which configuration triggered the match,
  /// especially when resolving optional values or generating error messages.
  final Flag matchedFlag;

  /// Constructs a [FlagFindResult] capturing the exact context of a successful CLI match.
  ///
  /// The [index] represents the current cursor position in the modified argument list,
  /// [type] classifies the syntax format, and [matchedFlag] is the originating definition.
  FlagFindResult(this.index, this.type, this.matchedFlag);
}
