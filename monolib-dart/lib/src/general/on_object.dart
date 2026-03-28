extension OnObject<T> on T {
  T also(void Function(T x) call) {
    call(this);
    return this;
  }

  R let<R>(R Function(T x) call) => call(this);

  T maybeLet(T Function(T x)? call) {
    if (call == null) return this;
    return call(this);
  }

  R Function() asArgumentIn<R>(R Function(T x) function) =>
      () => function(this);

  R castTo<R>() => this as R;

  String get quotingString => switch (this) {
    List<List> list =>
      '[\n${list.map((Object? list) => '  ${list.quotingString}').join('\n')}\n]',
    List list => Iterable.iterableToFullString(
      list.map((Object? x) => x.quotingString),
      '[',
      ']',
    ),
    Map _ => toString(),
    _ => "'$this'",
  };
}
