import 'dart:async';

Future<void> withLazyStringSink({
  StringSink? sink,
  StringSink Function()? sinkProvider,
  required Future<void> Function(StringSink Function() getSink) action,
}) async {
  if ((sink == null) == (sinkProvider == null)) {
    throw ArgumentError(
      'Exactly one of sink or sinkProvider must be provided.',
    );
  }

  bool ownsSink = false;
  StringSink? initializedSink;

  StringSink getSink() {
    initializedSink ??= sink ??
        () {
          ownsSink = true;
          return sinkProvider!();
        }();
    return initializedSink!;
  }

  try {
    await action(getSink);
  } finally {
    if (ownsSink && initializedSink != null) {
      if (initializedSink is StreamSink) {
        await (initializedSink as StreamSink).close();
      } else if (initializedSink is Sink) {
        (initializedSink as Sink).close();
      }
    }
  }
}
