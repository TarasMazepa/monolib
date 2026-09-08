extension OnNullableString on String? {
  String? emptyToNull() => switch (this) {
        null || '' => null,
        _ => this,
      };
}
