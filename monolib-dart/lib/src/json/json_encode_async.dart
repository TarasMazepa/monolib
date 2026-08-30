import 'dart:async';
import 'dart:convert';

import 'package:monolib_dart/src/common/with_lazy_string_sink.dart';
import 'package:monolib_dart/src/json/async_json_writable.dart';

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
