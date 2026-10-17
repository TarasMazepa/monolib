/// Provides [jsonEncodeAsync], an architectural foundation for streaming and
/// asynchronous JSON serialization.
///
/// This library exists to bypass the memory constraints and blocking nature
/// of standard [jsonEncode]. By progressively writing chunks to a [StringSink],
/// it enables the serialization of massive datasets, raw streams, or lazily
/// evaluated futures without retaining the full JSON tree in memory.
library;

import 'dart:async';
import 'dart:convert';

import 'package:monolib_dart/src/common/with_lazy_string_sink.dart';
import 'package:monolib_dart/src/json/async_json_writable.dart';

/// Asynchronously encodes an [object] into JSON and writes it to a sink in chunks.
///
/// Unlike standard [jsonEncode], this function is fully stream and future-aware.
/// It seamlessly resolves nested `Future`s and progressively consumes `Stream`s,
/// writing array items or object values as they arrive. This unbuffered approach
/// prevents blocking the event loop and significantly reduces memory overhead when
/// serializing massive or delayed structures (e.g. streaming API responses or
/// chunked file reads).
///
/// You must provide either an active [sink] or a lazy [sinkProvider], but not both.
/// See [withLazyStringSink] for detailed sink lifecycle management semantics.
///
/// - [object]: The root object to serialize. It supports standard primitives, maps,
///   iterables, natively awaited `Future`s, incrementally consumed `Stream`s, and
///   custom objects implementing `toJson()` or the streaming [AsyncJsonWritable] interface.
/// - [sink]: An already active, externally managed sink. The caller retains ownership
///   and is responsible for closing it.
/// - [sinkProvider]: A factory that lazily opens a sink (e.g. a file) only when the
///   first bytes are ready to be written. This utility takes ownership and will safely
///   close the sink upon completion or failure.
///
/// ### Example
///
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
