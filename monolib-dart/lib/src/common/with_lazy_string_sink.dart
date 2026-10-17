/// Provides [withLazyStringSink], an architectural utility for lazy resource allocation during asynchronous encoding.
library;

import 'dart:async';

/// A utility function that manages the lifecycle, lazy initialization, and resource
/// ownership of a [StringSink] for asynchronous encoding operations.
///
/// This function serves as the architectural foundation for asynchronous chunked
/// encoders (such as `jsonEncodeAsync`, `csvEncodeAsync`, and `jsonlEncodeAsync`)
/// by abstracting away manual sink validation and tear-down logic. It enforces
/// an inversion-of-control pattern: if the caller provides an already instantiated
/// [sink], the caller retains ownership and must close it. However, if the caller
/// provides a [sinkProvider], this function takes ownership, initializes the sink
/// only when requested, and automatically closes it upon completion or failure.
///
/// Lazy initialization protects against generating zero-byte or empty files when
/// an asynchronous operation yields no data to write. By deferring the execution
/// of [sinkProvider] until `getSink()` is explicitly invoked by the inner [action],
/// I/O resources are only allocated when necessary.
///
/// Either [sink] or [sinkProvider] MUST be provided, but not both. Throws an
/// [ArgumentError] if both are provided, or if neither are provided.
///
/// - [sink]: An active, externally managed [StringSink]. When provided, this utility
///   will NOT automatically close the sink after execution.
/// - [sinkProvider]: A factory callback that instantiates and returns a [StringSink].
///   When provided, this utility assumes ownership of the returned sink and will
///   safely invoke `.close()` (awaiting if it is a [StreamSink] or `dart:io` [IOSink])
///   in a `finally` block once [action] completes.
/// - [action]: The core asynchronous encoding logic. It receives a `getSink` callback,
///   which it must invoke to access the underlying [StringSink]. The `getSink` callback
///   caches and returns the active sink instance, triggering [sinkProvider] on its
///   first invocation if applicable.
///
/// Example:
/// ```dart
/// Future<void> customEncodeAsync(Stream<String> data, {StringSink Function()? sinkProvider}) {
///   return withLazyStringSink(
///     sinkProvider: sinkProvider,
///     action: (getSink) async {
///       // Using late final prevents initialization overhead until the stream yields data.
///       late final activeSink = getSink();
///       await for (final chunk in data) {
///         activeSink.write(chunk); // sinkProvider is invoked here on the first iteration.
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
