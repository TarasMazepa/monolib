import 'dart:async';

import 'package:monolib_dart/src/common/async_iterator_util.dart';
import 'package:monolib_dart/src/common/with_lazy_string_sink.dart';
import 'package:monolib_dart/src/json/json_encode_async.dart';

/// Asynchronously encodes a sequence of [items] into JSON Lines (JSONL) format
/// and writes each line to a destination [StringSink].
///
/// Accepts both [Iterable] and [Stream] collections via [iterateStreamOrIterable]
/// and encodes each item using [jsonEncodeAsync], followed by a trailing
/// newline (`\n`).
///
/// Sink initialization and lifecycle management are delegated to
/// [withLazyStringSink]. Exactly one of [sink] or [sinkProvider] must be
/// provided, or an [ArgumentError] is thrown.
///
/// - [items]: The [Iterable] or [Stream] of items to encode. Each item is
///   serialized via [jsonEncodeAsync], which supports nested [Future],
///   [Stream], and [Iterable] values, `toJson()` methods, and
///   `AsyncJsonWritable` objects.
/// - [sink]: An active, externally managed [StringSink]. If provided, the
///   caller retains ownership and is responsible for closing it.
/// - [sinkProvider]: A factory callback that lazily creates a [StringSink] when
///   the first item is ready to be written (preventing empty files when [items]
///   yields no elements). The created sink is closed automatically upon
///   completion or error if it implements [Sink] or [StreamSink].
///
/// Example:
/// ```dart
/// final buffer = StringBuffer();
/// final stream = Stream.fromIterable([
///   {'name': 'Alice', 'age': 30},
///   {'name': 'Bob', 'age': 25},
///   Future.value({'name': 'Charlie', 'age': 40}),
/// ]);
///
/// await jsonlEncodeAsync(
///   items: stream,
///   sink: buffer,
/// );
/// print(buffer.toString());
/// // Result: '{"name":"Alice","age":30}\n{"name":"Bob","age":25}\n{"name":"Charlie","age":40}\n'
/// ```
Future<void> jsonlEncodeAsync({
  required Object items,
  StringSink? sink,
  StringSink Function()? sinkProvider,
}) {
  return withLazyStringSink(
    sink: sink,
    sinkProvider: sinkProvider,
    action: (getSink) async {
      late final activeSink = getSink();
      await iterateStreamOrIterable(items, (item) async {
        try {
          await jsonEncodeAsync(object: item, sink: activeSink);
        } finally {
          activeSink.writeln();
        }
      });
    },
  );
}
