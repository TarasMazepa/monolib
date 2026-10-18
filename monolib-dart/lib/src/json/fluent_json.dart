import 'dart:convert';

/// A safe, path-tracked wrapper for traversing dynamic JSON structures.
///
/// [FluentJson] wraps decoded JSON values (such as those produced by
/// `dart:convert`) to simplify nested access and type-checked unboxing. It
/// maintains a [breadCrumbs] trail from the root node so that missing keys,
/// unexpected nulls, or type mismatches report the exact JSON path in the
/// thrown exception (for example, `Hierarchy from root json: $[users][0][id]`).
class FluentJson {
  /// The dynamic, untyped JSON payload wrapped at this hierarchy level.
  final dynamic json;

  /// The traversal history from the JSON root to this [json] element.
  final List<dynamic> breadCrumbs;

  /// Creates a new [FluentJson] with raw [json] and an optional trail of [breadCrumbs].
  ///
  /// This base constructor is usually called internally during tree traversals.
  const FluentJson({required this.json, this.breadCrumbs = const []});

  /// Instantiates a [FluentJson] root object by natively decoding the string payload.
  FluentJson.decode(String json) : this(json: jsonDecode(json));

  /// Instantiates an empty [FluentJson] object wrapping a null value.
  const FluentJson.empty() : this(json: null);

  /// Instantiates a [FluentJson] root from existing mapped [json], starting the path trail.
  FluentJson.root(this.json) : breadCrumbs = const [];

  Iterable<dynamic> _flattenBreadCrumbs(dynamic crumbs) sync* {
    if (crumbs is List) {
      for (final crumb in crumbs) {
        yield* _flattenBreadCrumbs(crumb);
      }
    } else {
      yield crumbs;
    }
  }

  String _describeForException() => '''Hierarchy from root json: ${[
        '\$'
      ].followedBy(_flattenBreadCrumbs(breadCrumbs).map((x) => "[$x]")).join()}

${jsonEncode(json)}''';

  dynamic _elementAt(dynamic accessor, {required bool couldBeNull}) {
    if (accessor is! String && accessor is! int) {
      throw Exception(
        "Expected json accessor '$accessor' type to be either String or int but got ${accessor.runtimeType}.",
      );
    }
    if (accessor is int && accessor < 0) {
      throw ArgumentError.value(
          accessor, 'accessor', 'Index must be non-negative.');
    }
    if (json == null) {
      if (!couldBeNull) {
        throw Exception("Tried to access [$accessor] on 'null'.");
      }
      return null;
    }
    if (couldBeNull &&
        accessor is int &&
        json is List &&
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

  /// Safely attempts to traverse into a child node using a key or index [accessor].
  ///
  /// Unlike [operator []], this method gracefully returns `null` if the child
  /// node does not exist, if accessing it yields a null value, or if an integer
  /// index [accessor] is out-of-bounds (`>= length`).
  ///
  /// Throws an [ArgumentError] if [accessor] is a negative integer.
  ///
  /// Example:
  /// ```dart
  /// final FluentJson? node = json.elementAt('optional_node');
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

  /// Traverses into a child node using a key or index [accessor], strictly expecting
  /// the node to exist and be non-null.
  ///
  /// If the node is missing or evaluates to `null`, this operator throws an explicit
  /// exception detailing the traversal error and breadcrumbs. If an integer index
  /// [accessor] is out-of-bounds (`>= length`), it will throw a [RangeError] wrapped
  /// in the path exception.
  ///
  /// Throws an [ArgumentError] if [accessor] is a negative integer.
  ///
  /// Example:
  /// ```dart
  /// final String name = json['user']['name'].unbox();
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

  /// Sequentially traverses through a provided list of [accessors] to fetch deeply
  /// nested structures.
  ///
  /// Throws an exception via [operator []] if any intermediate level is null.
  ///
  /// Example:
  /// ```dart
  /// final result = json.cascading(['users', 0, 'id']);
  /// ```
  FluentJson cascading(List<dynamic> accessors) =>
      accessors.fold(this, (result, accessor) => result[accessor]);

  /// Casts the raw wrapped [json] to the designated target type [T].
  ///
  /// If [T] is not nullable and the underlying value is null, or if the runtime type
  /// mismatches [T], it surfaces an explicit path exception.
  ///
  /// Example:
  /// ```dart
  /// final int age = json['age'].unbox<int>();
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

  /// Traverses into a child using [accessor] and immediately casts its value
  /// to the target type [T].
  ///
  /// If [T] is non-nullable, it employs strict unboxing. If [T] allows nulls,
  /// it relies on [unboxedElementAt] to permit graceful empty access.
  ///
  /// Throws an [ArgumentError] if [accessor] is a negative integer.
  ///
  /// Example:
  /// ```dart
  /// final String name = json.unboxed<String>('name');
  /// ```
  T unboxed<T>(dynamic accessor) =>
      null is! T ? this[accessor].unbox() : unboxedElementAt(accessor) as T;

  /// Safely traverses into an optional child using [accessor] and casts it to [T].
  ///
  /// Returns `null` if the node is absent, un-boxable, or out-of-bounds.
  ///
  /// Throws an [ArgumentError] if [accessor] is a negative integer.
  ///
  /// Example:
  /// ```dart
  /// final int? id = json.unboxedElementAt<int>('id');
  /// ```
  T? unboxedElementAt<T>(dynamic accessor) => elementAt(accessor)?.unbox();

  /// Interprets the current structure as a JSON array and iterates over its items.
  ///
  /// Yields individually path-tracked [FluentJson] instances for every item, indexing
  /// breadcrumbs so errors inside the loop clearly state their array index.
  ///
  /// Example:
  /// ```dart
  /// for (final item in json['users'].unboxIterable()) {
  ///   print(item['name'].unbox<String>());
  /// }
  /// ```
  Iterable<FluentJson> unboxIterable() sync* {
    for (final (index, item) in unbox<List>().indexed) {
      yield FluentJson(json: item, breadCrumbs: [breadCrumbs, index]);
    }
  }

  /// Maps an array of JSON objects to a strongly-typed Dart [List] using a closure.
  ///
  /// Applies the [mapper] to every path-tracked [FluentJson] node yielded by [unboxIterable].
  ///
  /// Example:
  /// ```dart
  /// final List<User> users = json['users'].unboxMappedList(User.fromJson);
  /// ```
  List<T> unboxMappedList<T>(T Function(FluentJson) mapper) =>
      unboxIterable().map(mapper).toList();
}
