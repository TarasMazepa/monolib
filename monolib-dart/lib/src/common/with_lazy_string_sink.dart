import 'dart:async';

/// Manages the lazy initialization and lifecycle of a [StringSink] for
/// asynchronous encoding operations.
///
/// If an existing [sink] is provided, the caller retains ownership and this
/// function does not close it. If [sinkProvider] is provided instead, this
/// function creates the sink lazily when `getSink()` is first called inside
/// [action] and automatically closes it (awaiting `close()` if it is a
/// [StreamSink] or `IOSink`, or calling [Sink.close] if it is a [Sink]) in a
/// `finally` block once [action] completes.
///
/// Deferring [sinkProvider] until `getSink()` is called avoids creating empty
/// files or buffers when an input stream yields no items.
///
/// Exactly one of [sink] or [sinkProvider] must be provided; otherwise, an
/// [ArgumentError] is thrown.
///
/// - [sink]: An existing, caller-managed [StringSink] that will not be closed
///   by this function.
/// - [sinkProvider]: A factory callback that creates a [StringSink] on first
///   use, which this function will close when [action] finishes.
/// - [action]: The asynchronous operation that receives a `getSink` callback
///   returning the active [StringSink].
///
/// Example:
/// ```dart
/// Future<void> customEncodeAsync(
///   Stream<String> data, {
///   StringSink Function()? sinkProvider,
/// }) {
///   return withLazyStringSink(
///     sinkProvider: sinkProvider,
///     action: (getSink) async {
///       late final activeSink = getSink();
///       await for (final chunk in data) {
///         activeSink.write(chunk);
///       }
///     },
///   );
/// }
/// ```
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
