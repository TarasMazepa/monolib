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

  StringSink? activeSink = sink;
  bool ownsSink = false;

  StringSink getSink() {
    if (activeSink == null) {
      activeSink = sinkProvider!();
      ownsSink = true;
    }
    return activeSink!;
  }

  Future<void> encode(Object? obj) async {
    if (obj == null) {
      getSink().write('null');
    } else if (obj is num || obj is bool) {
      getSink().write(obj.toString());
    } else if (obj is String) {
      getSink().write(jsonEncode(obj));
    } else if (obj is Future) {
      await encode(await obj);
    } else if (obj is Stream) {
      getSink().write('[');
      bool first = true;
      await for (final item in obj) {
        if (!first) getSink().write(',');
        await encode(item);
        first = false;
      }
      getSink().write(']');
    } else if (obj is Iterable) {
      getSink().write('[');
      bool first = true;
      for (final item in obj) {
        if (!first) getSink().write(',');
        await encode(item);
        first = false;
      }
      getSink().write(']');
    } else if (obj is Map) {
      getSink().write('{');
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
        if (!first) getSink().write(',');
        getSink().write(jsonEncode(key));
        getSink().write(':');
        await encode(entry.value);
        first = false;
      }
      getSink().write('}');
    } else {
      try {
        dynamic result = (obj as dynamic).toJson();
        await encode(result);
      } on NoSuchMethodError {
        // Let standard jsonEncode throw its normal error
        getSink().write(jsonEncode(obj));
      } catch (e) {
        // If toJson throws something else, we rethrow it
        rethrow;
      }
    }
  }

  try {
    await encode(object);
  } finally {
    if (ownsSink && activeSink != null) {
      if (activeSink is StreamSink) {
        await (activeSink as StreamSink).close();
      } else if (activeSink is Sink) {
        (activeSink as Sink).close();
      }
    }
  }
}
