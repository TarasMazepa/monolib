extension OnFunctionWithOneArgument<R, A> on R Function(A) {
  R Function() withAnArgument(A argument) => () => this(argument);
}
