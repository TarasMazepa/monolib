import 'dart:async';
import 'dart:convert';

import 'package:monolib_dart/src/common/with_lazy_string_sink.dart';
import 'package:monolib_dart/src/json/async_json_writable.dart';

/// Asynchronously encodes an [object] into JSON and writes it to a [StringSink]
/// in chunks.
///
/// Unlike standard [jsonEncode], this function resolves nested [Future]s and
/// progressively consumes [Stream]s, writing array items or object values as
/// they arrive without buffering the full JSON tree in memory.
///
/// Sink initialization and lifecycle management are delegated to
/// [withLazyStringSink]. Exactly one of [sink] or [sinkProvider] must be
/// provided, or an [ArgumentError] is thrown.
///
/// - [object]: The root object to serialize. Supports primitives, [Map]s,
///   [Iterable]s, awaited [Future]s, streamed [Stream]s, objects implementing
///   `toJson()`, and [AsyncJsonWritable] instances.
/// - [sink]: An active, externally managed [StringSink]. If provided, the
///   caller retains ownership and is responsible for closing it.
/// - [sinkProvider]: A factory callback that lazily creates a [StringSink] when
///   the first output is ready to be written. The created sink is closed
///   automatically upon completion or error if it implements [Sink] or
///   [StreamSink].
///
/// Example:
/// ```dart
/// final stream = Stream.fromIterable([1, 2, 3]);
/// final lazyData = {
///   'meta': 'chunked',
///   'values': stream,
/// };
///
/// final buffer = StringBuffer();
/// await jsonEncodeAsync(object: lazyData, sink: buffer);
/// print(buffer.toString()); // {"meta":"chunked","values":[1,2,3]}
/// ```
Future<void> jsonEncodeAsync({
  required Object? object,
  StringSink? sink,
  StringSink Function()? sinkProvider,
}) {
  return withLazyStringSink(
    sink: sink,
    sinkProvider: sinkProvider,
    action: (getSink) async {
      late final activeSink = getSink();

      Future<void> encode(Object? obj) async {
        if (obj == null) {
          activeSink.write('null');
        } else if (obj is num || obj is bool) {
          activeSink.write(obj.toString());
        } else if (obj is String) {
          activeSink.write(jsonEncode(obj));
        } else if (obj is Future) {
          await encode(await obj);
        } else if (obj is Stream) {
          bool first = true;
          await for (final item in obj) {
            if (first) {
              activeSink.write('[');
            } else {
              activeSink.write(',');
            }
            await encode(item);
            first = false;
          }
          if (first) activeSink.write('[');
          activeSink.write(']');
        } else if (obj is Iterable) {
          bool first = true;
          for (final item in obj) {
            if (first) {
              activeSink.write('[');
            } else {
              activeSink.write(',');
            }
            await encode(item);
            first = false;
          }
          if (first) activeSink.write('[');
          activeSink.write(']');
        } else if (obj is Map) {
          bool first = true;
          for (final entry in obj.entries) {
            dynamic key = entry.key;
            if (key is Future) {
              key = await key;
            }

            if (key is! String) {
              // Force the standard error message for map keys
              jsonEncode({key: null});
            }
            if (first) {
              activeSink.write('{');
            } else {
              activeSink.write(',');
            }
            activeSink.write(jsonEncode(key));
            activeSink.write(':');
            await encode(entry.value);
            first = false;
          }
          if (first) activeSink.write('{');
          activeSink.write('}');
        } else if (obj is AsyncJsonWritable) {
          await obj.writeJsonAsync(activeSink, encode);
        } else {
          try {
            dynamic result = (obj as dynamic).toJson();
            await encode(result);
          } on NoSuchMethodError {
            // Let standard jsonEncode throw its normal error
            activeSink.write(jsonEncode(obj));
          } catch (e) {
            // If toJson throws something else, we rethrow it
            rethrow;
          }
        }
      }

      await encode(object);
    },
  );
}
