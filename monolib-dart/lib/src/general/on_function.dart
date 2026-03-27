extension OnFunction<R, A> on R Function(A) {
  R Function() withAnArgument(A argument) =>
      () => this(argument);
}
