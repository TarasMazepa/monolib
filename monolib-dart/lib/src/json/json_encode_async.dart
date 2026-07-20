import 'dart:async';
import 'dart:convert';

Future<void> jsonEncodeAsync({
  required Object? object,
  StringSink? sink,
  StringSink Function()? sinkProvider,
}) async {
  if ((sink == null) == (sinkProvider == null)) {
    throw ArgumentError(
        'Exactly one of sink or sinkProvider must be provided.');
  }

  bool ownsSink = false;
  late StringSink activeSink = sink ??
      () {
        ownsSink = true;
        return sinkProvider!();
      }();

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

  try {
    await encode(object);
  } finally {
    if (ownsSink) {
      if (activeSink is StreamSink) {
        await (activeSink as StreamSink).close();
      } else if (activeSink is Sink) {
        (activeSink as Sink).close();
      }
    }
  }
}
