/// An architectural result type that resolves the ambiguity between a CLI flag
/// being completely omitted from the arguments list versus being present but
/// without an accompanying value.
///
/// In the repository's destructive parsing architecture, arguments are actively
/// removed from the raw list as they are evaluated. The standard `Flag.getFlagValue`
/// throws an exception if a value is expected but missing. [OptionalFlagResult]
/// acts as a safe, explicit wrapper for optional arguments, enabling consumers
/// to gracefully distinguish between a user skipping a flag, or providing it
/// as a standalone toggle.
///
/// Typical usage pairs this with `Flag.getOptionalFlagValue`:
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

/// Indicates that the target `Flag` was not found within the raw CLI argument list.
///
/// When this result is returned by `Flag.getOptionalFlagValue`, the underlying
/// argument list remains unmutated because no matching tokens were destructively consumed.
class FlagNotPresent extends OptionalFlagResult {}

/// Indicates that the target `Flag` was successfully matched and destructively
/// removed from the CLI argument list, optionally containing an extracted [value].
///
/// Depending on the parsing context, [value] may be captured from the sequentially
/// subsequent token.
class FlagPresent extends OptionalFlagResult {
  /// The optional string value that immediately followed the matched flag in the
  /// argument list.
  ///
  /// This will be `null` if the flag was provided as a standalone toggle at the
  /// end of the argument list, or if it was part of a short-combined flag group
  /// (e.g., `-xvf` where `-x` is the matched flag).
  final String? value;

  /// Constructs a result indicating the flag was found, optionally wrapping its
  /// accompanying [value].
  FlagPresent(this.value);
}
