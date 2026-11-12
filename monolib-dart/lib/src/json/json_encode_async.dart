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
        late final Future<void>? Function(Object? obj) encode;

        Future<void> encodeFutureAsync(Future pendingFuture) async {
          final resolved = await pendingFuture;
          final future = encode(resolved);
          if (future != null) {
            activeSink.flush();
            await future;
          }
        }

        Future<void> encodeStreamAsync(Stream stream) async {
          bool first = true;
          await for (final item in stream) {
            if (first) {
              activeSink.write('[');
              first = false;
            } else {
              activeSink.write(',');
            }
            if (!_writePrimitive(item, activeSink)) {
              final future = encode(item);
              if (future != null) {
                activeSink.flush();
                await future;
              }
            }
            activeSink.flush();
          }
          if (first) activeSink.write('[');
          activeSink.write(']');
        }

        Future<void> resumeIterableAsync(
          Iterator iterator,
          Future<void> pendingFuture,
        ) async {
          activeSink.flush();
          await pendingFuture;
          while (iterator.moveNext()) {
            activeSink.write(',');
            final item = iterator.current;
            if (!_writePrimitive(item, activeSink)) {
              final future = encode(item);
              if (future != null) {
                activeSink.flush();
                await future;
              }
            }
          }
          activeSink.write(']');
        }

        Future<void> resumeMapFromValueAsync(
          Iterator<MapEntry> iterator, [
          Future<void>? pendingValueFuture,
        ]) async {
          if (pendingValueFuture != null) {
            activeSink.flush();
            await pendingValueFuture;
          }
          while (iterator.moveNext()) {
            dynamic key = iterator.current.key;
            if (key is Future) {
              activeSink.flush();
              key = await key;
            }
            if (key is! String) {
              jsonEncode({key: null});
            }
            activeSink.write(',');
            activeSink.write(jsonEncode(key));
            activeSink.write(':');
            final value = iterator.current.value;
            if (!_writePrimitive(value, activeSink)) {
              final future = encode(value);
              if (future != null) {
                activeSink.flush();
                await future;
              }
            }
          }
          activeSink.write('}');
        }

        Future<void> resumeMapFromKeyAsync(
          Iterator<MapEntry> iterator,
          Future pendingKey,
          dynamic value,
        ) async {
          dynamic key = await pendingKey;
          if (key is! String) {
            jsonEncode({key: null});
          }
          activeSink.write(jsonEncode(key));
          activeSink.write(':');
          final future = encode(value);
          await resumeMapFromValueAsync(iterator, future);
        }

        encode = (Object? obj) {
          if (_writePrimitive(obj, activeSink)) {
            return null;
          } else if (obj is Future) {
            activeSink.flush();
            return encodeFutureAsync(obj);
          } else if (obj is Stream) {
            activeSink.flush();
            return encodeStreamAsync(obj);
          } else if (obj is Iterable) {
            bool first = true;
            final iterator = obj.iterator;
            while (iterator.moveNext()) {
              activeSink.write(first ? '[' : ',');
              first = false;
              final item = iterator.current;
              if (!_writePrimitive(item, activeSink)) {
                final future = encode(item);
                if (future != null) {
                  return resumeIterableAsync(iterator, future);
                }
              }
            }
            if (first) activeSink.write('[');
            activeSink.write(']');
            return null;
          } else if (obj is Map) {
            bool first = true;
            final iterator = obj.entries.iterator;
            while (iterator.moveNext()) {
              activeSink.write(first ? '{' : ',');
              first = false;
              dynamic key = iterator.current.key;
              if (key is Future) {
                activeSink.flush();
                return resumeMapFromKeyAsync(
                  iterator,
                  key,
                  iterator.current.value,
                );
              }
              if (key is! String) {
                jsonEncode({key: null});
              }
              activeSink.write(jsonEncode(key));
              activeSink.write(':');
              final value = iterator.current.value;
              if (!_writePrimitive(value, activeSink)) {
                final future = encode(value);
                if (future != null) {
                  return resumeMapFromValueAsync(iterator, future);
                }
              }
            }
            if (first) activeSink.write('{');
            activeSink.write('}');
            return null;
          } else if (obj is AsyncJsonWritable) {
            activeSink.flush();
            return obj.writeJsonAsync(activeSink, (child) async {
              final future = encode(child);
              if (future != null) {
                activeSink.flush();
                await future;
              }
            });
          } else {
            try {
              dynamic result = (obj as dynamic).toJson();
              if (result is Future) {
                activeSink.flush();
                return encodeFutureAsync(result);
              }
              return encode(result);
            } on NoSuchMethodError {
              activeSink.write(jsonEncode(obj));
              return null;
            } catch (e) {
              rethrow;
            }
          }
        };

        final future = encode(object);
        if (future != null) {
          activeSink.flush();
          await future;
        }
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
