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
      final bufferedSink = BufferedStringSink.lazy(getSink);

      try {
        Future<void> encode(Object? obj) async {
          if (obj == null) {
            bufferedSink.write('null');
          } else if (obj is num || obj is bool) {
            bufferedSink.write(obj.toString());
          } else if (obj is String) {
            bufferedSink.write(jsonEncode(obj));
          } else if (obj is Future) {
            bufferedSink.flush();
            await encode(await obj);
          } else if (obj is Stream) {
            bool first = true;
            bufferedSink.flush();
            await for (final item in obj) {
              if (first) {
                bufferedSink.write('[');
              } else {
                bufferedSink.write(',');
              }
              await encode(item);
              first = false;
              bufferedSink.flush();
            }
            if (first) bufferedSink.write('[');
            bufferedSink.write(']');
          } else if (obj is Iterable) {
            bool first = true;
            for (final item in obj) {
              if (first) {
                bufferedSink.write('[');
              } else {
                bufferedSink.write(',');
              }
              first = false;
              if (item == null) {
                bufferedSink.write('null');
              } else if (item is num || item is bool) {
                bufferedSink.write(item.toString());
              } else if (item is String) {
                bufferedSink.write(jsonEncode(item));
              } else {
                await encode(item);
              }
            }
            if (first) bufferedSink.write('[');
            bufferedSink.write(']');
          } else if (obj is Map) {
            bool first = true;
            for (final entry in obj.entries) {
              dynamic key = entry.key;
              if (key is Future) {
                bufferedSink.flush();
                key = await key;
              }

              if (key is! String) {
                // Force the standard error message for map keys
                jsonEncode({key: null});
              }
              if (first) {
                bufferedSink.write('{');
              } else {
                bufferedSink.write(',');
              }
              bufferedSink.write(jsonEncode(key));
              bufferedSink.write(':');
              first = false;

              final value = entry.value;
              if (value == null) {
                bufferedSink.write('null');
              } else if (value is num || value is bool) {
                bufferedSink.write(value.toString());
              } else if (value is String) {
                bufferedSink.write(jsonEncode(value));
              } else {
                await encode(value);
              }
            }
            if (first) bufferedSink.write('{');
            bufferedSink.write('}');
          } else if (obj is AsyncJsonWritable) {
            bufferedSink.flush();
            await obj.writeJsonAsync(bufferedSink, encode);
          } else {
            try {
              dynamic result = (obj as dynamic).toJson();
              if (result is Future) {
                bufferedSink.flush();
              }
              await encode(result);
            } on NoSuchMethodError {
              // Let standard jsonEncode throw its normal error
              bufferedSink.write(jsonEncode(obj));
            } catch (e) {
              // If toJson throws something else, we rethrow it
              rethrow;
            }
          }
        }

        await encode(object);
      } finally {
        bufferedSink.flush();
      }
    },
  );
}
