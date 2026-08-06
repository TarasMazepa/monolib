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

  R castTo<R>() => this as R;
}
