sealed class OptionalFlagResult {}

class FlagNotPresent extends OptionalFlagResult {}

class FlagPresent extends OptionalFlagResult {
  final String? value;
  FlagPresent(this.value);
}
