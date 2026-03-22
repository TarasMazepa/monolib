import 'dart:convert';
import 'dart:async';

Future<void> jsonEncodeAsync(Object? object, StringSink sink) async {
  if (object == null) {
    sink.write('null');
  } else if (object is num || object is bool) {
    sink.write(object.toString());
  } else if (object is String) {
    sink.write(jsonEncode(object));
  } else if (object is Future) {
    await jsonEncodeAsync(await object, sink);
  } else if (object is Stream) {
    sink.write('[');
    bool first = true;
    await for (final item in object) {
      if (!first) sink.write(',');
      await jsonEncodeAsync(item, sink);
      first = false;
    }
    sink.write(']');
  } else if (object is Iterable) {
    sink.write('[');
    bool first = true;
    for (final item in object) {
      if (!first) sink.write(',');
      await jsonEncodeAsync(item, sink);
      first = false;
    }
    sink.write(']');
  } else if (object is Map) {
    sink.write('{');
    bool first = true;
    for (final entry in object.entries) {
      dynamic key = entry.key;
      if (key is Future) {
        key = await key;
      }

      if (key is! String) {
        // Force the standard error message for map keys
        jsonEncode({key: null});
      }
      if (!first) sink.write(',');
      sink.write(jsonEncode(key));
      sink.write(':');
      await jsonEncodeAsync(entry.value, sink);
      first = false;
    }
    sink.write('}');
  } else {
    try {
      dynamic result = (object as dynamic).toJson();
      await jsonEncodeAsync(result, sink);
    } on NoSuchMethodError {
      // Let standard jsonEncode throw its normal error
      sink.write(jsonEncode(object));
    } catch (e) {
      // If toJson throws something else, we rethrow it
      rethrow;
    }
  }
}
