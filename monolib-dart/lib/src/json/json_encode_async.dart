import 'dart:async';
import 'dart:convert';

import 'package:monolib_dart/src/common/buffered_string_sink.dart';
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
      final activeSink = BufferedStringSink.lazy(getSink);

      try {
        Future<void> encode(Object? obj) async {
          if (_writePrimitive(obj, activeSink)) {
            return;
          } else if (obj is Future) {
            activeSink.flush();
            await encode(await obj);
          } else if (obj is Stream) {
            bool first = true;
            activeSink.flush();
            await for (final item in obj) {
              if (first) {
                activeSink.write('[');
              } else {
                activeSink.write(',');
              }
              if (!_writePrimitive(item, activeSink)) {
                await encode(item);
              }
              first = false;
              activeSink.flush();
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
              first = false;
              if (!_writePrimitive(item, activeSink)) {
                await encode(item);
              }
            }
            if (first) activeSink.write('[');
            activeSink.write(']');
          } else if (obj is Map) {
            bool first = true;
            for (final entry in obj.entries) {
              dynamic key = entry.key;
              if (key is Future) {
                activeSink.flush();
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
              first = false;

              final value = entry.value;
              if (!_writePrimitive(value, activeSink)) {
                await encode(value);
              }
            }
            if (first) activeSink.write('{');
            activeSink.write('}');
          } else if (obj is AsyncJsonWritable) {
            activeSink.flush();
            await obj.writeJsonAsync(activeSink, encode);
          } else {
            try {
              dynamic result = (obj as dynamic).toJson();
              if (result is Future) {
                activeSink.flush();
              }
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
      } finally {
        activeSink.flush();
      }
    },
  );
}

bool _writePrimitive(Object? value, StringSink sink) {
  if (value == null) {
    sink.write('null');
    return true;
  } else if (value is num || value is bool) {
    sink.write(value.toString());
    return true;
  } else if (value is String) {
    sink.write(jsonEncode(value));
    return true;
  }
  return false;
}
