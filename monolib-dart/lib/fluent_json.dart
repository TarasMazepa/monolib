/// A comprehensive library for safe, fluent traversal and serialization of JSON data.
///
/// This library provides the [FluentJson] API, an architectural solution for
/// parsing and extracting dynamically-typed JSON structures in Dart. Instead of
/// performing manual runtime type-checking and null validation on loosely-typed
/// `Map<String, dynamic>` maps, consumers can use [FluentJson] to traverse paths safely.
///
/// It actively tracks "breadcrumbs" (the path taken through the JSON tree) to
/// generate highly descriptive error messages when parsing fails (e.g., missing
/// keys or unexpected types), enabling faster debugging and validation.
///
/// It also exports utilities like [LazyJson] to optimize the deferred encoding
/// of expensive operations, and ergonomic extensions on `String` and `FluentJson`
/// (like `parseAsFluentJson` and `asDateTime`) to simplify common integration workflows.
library;

export 'src/json/fluent_json.dart';
export 'src/json/lazy_json.dart';
export 'src/json/on_fluent_json.dart';
export 'src/json/on_string.dart';
