extension OnBool on bool {
  int? compareChain(bool other) {
    if (this == other) return null;
    return this ? 1 : -1;
  }
}
