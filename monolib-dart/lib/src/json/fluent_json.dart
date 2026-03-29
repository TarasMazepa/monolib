import 'dart:convert';

class FluentJson {
  final dynamic json;
  final List<dynamic> breadCrumbs;

  const FluentJson({required this.json, this.breadCrumbs = const []});

  FluentJson.decode(String json) : this(json: jsonDecode(json));

  const FluentJson.empty() : this(json: null);

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

  FluentJson? elementAt(dynamic accessor) {
    return switch (_elementAt(accessor, couldBeNull: true)) {
      null => null,
      final json => FluentJson(
          json: json,
          breadCrumbs: [breadCrumbs, accessor],
        ),
    };
  }

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

  FluentJson cascading(List<dynamic> accessors) =>
      accessors.fold(this, (result, accessor) => result[accessor]);

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

  T unboxed<T>(dynamic accessor) =>
      null is! T ? this[accessor].unbox() : unboxedElementAt(accessor) as T;

  T? unboxedElementAt<T>(dynamic accessor) => elementAt(accessor)?.unbox();

  Iterable<FluentJson> unboxIterable() sync* {
    for (final (index, item) in unbox<List>().indexed) {
      yield FluentJson(json: item, breadCrumbs: [breadCrumbs, index]);
    }
  }

  List<T> unboxMappedList<T>(T Function(FluentJson) mapper) =>
      unboxIterable().map(mapper).toList();
}
