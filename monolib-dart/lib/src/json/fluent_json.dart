import 'dart:convert';

/// A wrapper around dynamically typed JSON data that provides a fluent,
/// predictable, and safe API for traversing deep JSON structures.
///
/// In Dart, navigating loosely-typed `Map<String, dynamic>` or `List<dynamic>`
/// structures often requires manual type-checking, repetitive null-checks, and
/// results in opaque `TypeError`s when the data shape mismatches expectations.
///
/// [FluentJson] solves this by maintaining the path taken through the JSON tree
/// (the [breadCrumbs]). If an unexpected type or a missing element is encountered
/// during traversal or unboxing, it throws highly descriptive exceptions
/// containing the exact JSON path (e.g., `$[users][0][name]`) and the
/// stringified context, allowing developers to immediately pinpoint parsing
/// failures without a debugger.
///
/// It supports both strict traversal via `operator []` (which throws if a path
/// does not exist) and safe traversal via [elementAt] (which gracefully returns
/// `null` for missing paths).
///
/// ### Example Usage
/// ```dart
/// final rawJson = '{"data": {"users": [{"id": 1, "name": "Alice"}]}}';
/// final json = FluentJson.decode(rawJson);
///
/// // Fluent traversal and type-safe unboxing.
/// final firstUserName = json['data']['users'][0]['name'].unbox<String>();
/// print(firstUserName); // "Alice"
///
/// // Safe traversal of potentially missing properties.
/// final missing = json['data']['settings']?.elementAt('theme')?.unbox<String>();
/// print(missing); // null
/// ```
class FluentJson {
  /// The underlying JSON value at the current path.
  ///
  /// This typically contains a `Map<String, dynamic>`, `List<dynamic>`,
  /// `String`, `num`, `bool`, or `null`.
  final dynamic json;

  /// The traversal path taken from the root to reach the current [json] value.
  ///
  /// This list can contain nested lists of crumbs due to performance optimizations
  /// when constructing new [FluentJson] instances during deep traversal. It is
  /// flattened on demand when generating error messages.
  final List<dynamic> breadCrumbs;

  /// Constructs a new [FluentJson] node with the specified [json] data
  /// and optional [breadCrumbs].
  ///
  /// Typically, you would use [FluentJson.decode] or [FluentJson.root] for
  /// initial creation, and the library will automatically pass down the updated
  /// [breadCrumbs] during traversal.
  const FluentJson({required this.json, this.breadCrumbs = const []});

  /// Parses the raw [json] string using [jsonDecode] and wraps the result in
  /// a [FluentJson] instance representing the root of the parsed structure.
  ///
  /// ### Example
  /// ```dart
  /// final json = FluentJson.decode('{"status": "ok"}');
  /// ```
  FluentJson.decode(String json) : this(json: jsonDecode(json));

  /// Creates a [FluentJson] instance that wraps `null`.
  ///
  /// This can be used as a default or placeholder value representing
  /// an explicitly empty JSON document.
  const FluentJson.empty() : this(json: null);

  /// Wraps an already parsed JSON object (e.g., a `Map` or `List`) as the root.
  ///
  /// This initializes the [breadCrumbs] to an empty list.
  ///
  /// ### Example
  /// ```dart
  /// final parsed = {'id': 42};
  /// final json = FluentJson.root(parsed);
  /// ```
  FluentJson.root(this.json) : breadCrumbs = const [];

  /// Flattens the hierarchically structured [crumbs] list into a flat stream.
  ///
  /// Since breadcrumbs are accumulated lazily as nested lists (e.g., `[[], 'a']`)
  /// to avoid expensive list copying during traversal, this method unwinds them
  /// into a sequential stream of accessors.
  Iterable<dynamic> _flattenBreadCrumbs(dynamic crumbs) sync* {
    if (crumbs is List) {
      for (final crumb in crumbs) {
        yield* _flattenBreadCrumbs(crumb);
      }
    } else {
      yield crumbs;
    }
  }

  /// Generates a developer-friendly diagnostic string for exceptions.
  ///
  /// This string includes the full JSON path (e.g., `$[data][users][0]`)
  /// derived from [_flattenBreadCrumbs], along with a stringified representation
  /// of the current [json] context to help identify parsing issues.
  String _describeForException() => '''Hierarchy from root json: ${[
        '\$'
      ].followedBy(_flattenBreadCrumbs(breadCrumbs).map((x) => "[$x]")).join()}

${jsonEncode(json)}''';

  /// Internal helper to extract an element using an [accessor] (String key or int index).
  ///
  /// If [couldBeNull] is `true`, encountering `null` along the path or going
  /// out of bounds in a list returns `null`. If `false`, it throws an exception
  /// providing the exact JSON path and context using [_describeForException].
  dynamic _elementAt(dynamic accessor, {required bool couldBeNull}) {
    if (accessor is! String && accessor is! int) {
      throw Exception(
        "Expected json accessor '$accessor' type to be either String or int but got ${accessor.runtimeType}.",
      );
    }
    if (json == null) {
      if (!couldBeNull) {
        throw Exception("Tried to access [$accessor] on 'null'.");
      }
      return null;
    }
    if (accessor is int &&
        json is List &&
        accessor >= 0 &&
        accessor >= json.length) {
      return null;
    }
    try {
      return json[accessor];
    } catch (e) {
      throw Exception('''json[$accessor] thrown an exception.
${_describeForException()}

Original exception:
$e''');
    }
  }

  /// Safely traverses to a child element using the given [accessor].
  ///
  /// Unlike `operator []`, this method gracefully handles missing keys, out of
  /// bounds indices, or attempts to traverse `null` values by returning `null`.
  ///
  /// The [accessor] must be a `String` (for object properties) or an `int`
  /// (for array indices).
  ///
  /// ### Example
  /// ```dart
  /// final json = FluentJson.decode('{"a": 1}');
  /// final b = json.elementAt('b'); // Returns null safely
  /// ```
  FluentJson? elementAt(dynamic accessor) {
    return switch (_elementAt(accessor, couldBeNull: true)) {
      null => null,
      final json => FluentJson(
          json: json,
          breadCrumbs: [breadCrumbs, accessor],
        ),
    };
  }

  /// Strictly traverses to a child element using the given [accessor].
  ///
  /// This operator expects the child element to exist. If the path is invalid,
  /// the underlying value is `null`, or an out of bounds index is requested,
  /// it throws an exception with a detailed breadcrumb trace.
  ///
  /// The [accessor] must be a `String` (for object properties) or an `int`
  /// (for array indices).
  ///
  /// ### Example
  /// ```dart
  /// final json = FluentJson.decode('{"users": ["Alice"]}');
  /// final firstUser = json['users'][0];
  /// ```
  FluentJson operator [](dynamic accessor) {
    return switch (_elementAt(accessor, couldBeNull: false)) {
      null => throw Exception('''json[$accessor] resulted in null.
${_describeForException()}'''),
      final json => FluentJson(
          json: json,
          breadCrumbs: [breadCrumbs, accessor],
        ),
    };
  }

  /// Sequentially applies a list of [accessors] to traverse deep into the JSON tree.
  ///
  /// This is equivalent to chaining `operator []` multiple times. If any step
  /// along the path fails, it throws an exception with the full breadcrumb trace.
  ///
  /// ### Example
  /// ```dart
  /// final json = FluentJson.decode('{"a": {"b": {"c": 42}}}');
  /// final result = json.cascading(['a', 'b', 'c']).unbox<int>(); // 42
  /// ```
  FluentJson cascading(List<dynamic> accessors) =>
      accessors.fold(this, (result, accessor) => result[accessor]);

  /// Extracts and casts the underlying [json] value to the specified type [T].
  ///
  /// If the underlying type does not match [T], or if [T] is non-nullable but
  /// the underlying value is `null`, it throws a highly descriptive exception
  /// detailing the JSON path and expected vs. actual types.
  ///
  /// If [T] is explicitly [FluentJson], it returns `this`.
  ///
  /// ### Example
  /// ```dart
  /// final json = FluentJson.decode('{"count": 10}');
  /// final count = json['count'].unbox<int>(); // 10
  /// ```
  T unbox<T>() {
    if (T == FluentJson) {
      return this as T;
    }
    if (null is! T && json == null) {
      throw Exception(
        '''Expected json to be a non nullable value but found null.
${_describeForException()}''',
      );
    }
    if (json is! T) {
      throw Exception(
        '''Expected json to be type $T but found ${json.runtimeType}.
${_describeForException()}''',
      );
    }
    return json as T;
  }

  /// A convenience method to access a child via [accessor] and immediately [unbox] it.
  ///
  /// If [T] is non-nullable, it performs strict traversal (equivalent to using
  /// `operator []` and `unbox<T>()`). If [T] is nullable, it performs safe
  /// traversal (equivalent to [elementAt] and `unbox<T>()`).
  ///
  /// ### Example
  /// ```dart
  /// final json = FluentJson.decode('{"name": "Bob"}');
  /// final name = json.unboxed<String>('name'); // "Bob"
  /// final age = json.unboxed<int?>('age'); // null
  /// ```
  T unboxed<T>(dynamic accessor) =>
      null is! T ? this[accessor].unbox() : unboxedElementAt(accessor) as T;

  /// A convenience method to safely access a child via [accessor] and [unbox] it.
  ///
  /// This relies on [elementAt] so it does not throw if the [accessor] is missing;
  /// instead, it returns `null`. If the element exists, it casts it to [T].
  ///
  /// ### Example
  /// ```dart
  /// final json = FluentJson.decode('{"name": "Bob"}');
  /// final age = json.unboxedElementAt<int>('age'); // Returns null safely
  /// ```
  T? unboxedElementAt<T>(dynamic accessor) => elementAt(accessor)?.unbox();

  /// Unboxes the current JSON node as a list and iterates over its items.
  ///
  /// It yields a new [FluentJson] wrapper for each element in the underlying
  /// JSON list, automatically updating the breadcrumbs with the array indices.
  /// Throws an exception if the underlying [json] is not a `List`.
  ///
  /// ### Example
  /// ```dart
  /// final json = FluentJson.decode('{"items": [1, 2]}');
  /// for (final item in json['items'].unboxIterable()) {
  ///   print(item.unbox<int>());
  /// }
  /// ```
  Iterable<FluentJson> unboxIterable() sync* {
    for (final (index, item) in unbox<List>().indexed) {
      yield FluentJson(json: item, breadCrumbs: [breadCrumbs, index]);
    }
  }

  /// Unboxes the current JSON node as a list, iterates over its items, and
  /// transforms each item using the provided [mapper] function.
  ///
  /// This is a convenient shorthand for `unboxIterable().map(mapper).toList()`.
  /// Throws an exception if the underlying [json] is not a `List`.
  ///
  /// ### Example
  /// ```dart
  /// final json = FluentJson.decode('{"items": ["a", "b"]}');
  /// final upperItems = json['items'].unboxMappedList((node) => node.unbox<String>().toUpperCase());
  /// print(upperItems); // ["A", "B"]
  /// ```
  List<T> unboxMappedList<T>(T Function(FluentJson) mapper) =>
      unboxIterable().map(mapper).toList();
}
