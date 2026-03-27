extension EmptyToNull on String? {
  String? emptyToNull() => switch (this) {
        null || '' => null,
        _ => this,
      };
}
