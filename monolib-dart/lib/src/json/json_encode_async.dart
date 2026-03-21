import 'dart:convert';
import 'dart:async';

Stream<String> jsonEncodeAsync(dynamic object) async* {
  if (object == null) {
    yield 'null';
  } else if (object is num || object is bool) {
    yield object.toString();
  } else if (object is String) {
    yield jsonEncode(object);
  } else if (object is Future) {
    yield* jsonEncodeAsync(await object);
  } else if (object is Stream) {
    yield '[';
    bool first = true;
    await for (final item in object) {
      if (!first) yield ',';
      yield* jsonEncodeAsync(item);
      first = false;
    }
    yield ']';
  } else if (object is Iterable) {
    yield '[';
    bool first = true;
    for (final item in object) {
      if (!first) yield ',';
      yield* jsonEncodeAsync(item);
      first = false;
    }
    yield ']';
  } else if (object is Map) {
    yield '{';
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
      if (!first) yield ',';
      yield jsonEncode(key);
      yield ':';
      yield* jsonEncodeAsync(entry.value);
      first = false;
    }
    yield '}';
  } else {
    try {
      dynamic result = (object as dynamic).toJson();
      yield* jsonEncodeAsync(result);
    } on NoSuchMethodError {
      // Let standard jsonEncode throw its normal error
      yield jsonEncode(object);
    } catch (e) {
      // If toJson throws something else, we rethrow it
      rethrow;
    }
  }
}
