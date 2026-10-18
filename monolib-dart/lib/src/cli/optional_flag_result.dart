import 'package:monolib_dart/src/cli/flag.dart';

/// The result of extracting an optional value for a [Flag] from an argument
/// list.
///
/// Returned by [Flag.getOptionalFlagValue] to distinguish between a flag being
/// absent ([FlagNotPresent]) and a flag being present with or without an
/// accompanying value ([FlagPresent]).
///
/// Example:
/// ```dart
/// final outputFlag = Flag(short: '-o', long: '--output', description: 'Output file');
/// final result = outputFlag.getOptionalFlagValue(args);
///
/// switch (result) {
///   case FlagNotPresent():
///     print('Using default output settings');
///   case FlagPresent(:final value?):
///     print('Writing to custom file: $value');
///   case FlagPresent(value: null):
///     print('Writing to standard out (flag present, no value)');
/// }
/// ```
sealed class OptionalFlagResult {}

/// Indicates that the target [Flag] was not present in the argument list.
class FlagNotPresent extends OptionalFlagResult {}

/// Indicates that the target [Flag] was matched and removed from the argument
/// list, optionally with an extracted [value].
class FlagPresent extends OptionalFlagResult {
  /// The argument value that immediately followed the matched flag, or `null`
  /// if no value was provided.
  ///
  /// This is `null` when the flag appeared at the end of the argument list or
  /// as part of a combined short-flag group (e.g., `-xvf`).
  final String? value;

  /// Creates a [FlagPresent] result with the optional [value].
  FlagPresent(this.value);
}
