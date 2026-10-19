# Monolib — Complete API Reference & Documentation

> Single-file source of truth for all public APIs across `monolib_dart`, `monolib_flutter`, and `monolib_openrouter`.
> Auto-generated from exported library declarations and Dartdoc comments.

## Table of Contents

- [monolib_dart](#monolib_dart)
  - [Pillar — Dependency Injection & State Management](#monolib_dart-pillar-dart) (`package:monolib_dart/pillar.dart`)
  - [FluentJson — Dynamic JSON Navigation & Unboxing](#monolib_dart-fluent_json-dart) (`package:monolib_dart/fluent_json.dart`)
  - [Async JSON — Non-blocking Streaming JSON Serialization](#monolib_dart-json_encode_async-dart) (`package:monolib_dart/json_encode_async.dart`)
  - [Reactive Streams — Stream/Sink Extensions & Composite Event Sinks](#monolib_dart-stream-dart) (`package:monolib_dart/stream.dart`)
  - [CSV — Streaming CSV Encoders, Decoders & Batchers](#monolib_dart-csv-dart) (`package:monolib_dart/csv.dart`)
  - [JSONL — Streaming JSON Lines Encoders, Decoders & Batchers](#monolib_dart-jsonl-dart) (`package:monolib_dart/jsonl.dart`)
  - [CLI — Command-Line Flag Parser](#monolib_dart-cli-dart) (`package:monolib_dart/cli.dart`)
  - [I/O — File System, I/O Sinks & Batch JSONL Writers](#monolib_dart-io-dart) (`package:monolib_dart/io.dart`)
  - [Zalgo — Zalgo Text Encoding & Decoding](#monolib_dart-zalgo-dart) (`package:monolib_dart/zalgo.dart`)
  - [Core Utilities — Extensions, Data Structures & Tables](#monolib_dart-monolib_dart-dart) (`package:monolib_dart/monolib_dart.dart`)
- [monolib_flutter](#monolib_flutter)
  - [Flutter Utilities — Widgets, Context/Scroll Extensions & Pillar Listenable](#monolib_flutter-monolib_flutter-dart) (`package:monolib_flutter/monolib_flutter.dart`)
  - [Flutter Zalgo — Text Range Mapping for Flutter Text Editing](#monolib_flutter-zalgo-dart) (`package:monolib_flutter/zalgo.dart`)
- [monolib_openrouter](#monolib_openrouter)
  - [OpenRouter Utilities — Streaming Converters, Sinks & Timeouts](#monolib_openrouter-monolib_openrouter-dart) (`package:monolib_openrouter/monolib_openrouter.dart`)

---

## `monolib_dart`

General-purpose utilities, streaming codecs (CSV, JSONL), async JSON, Pillar DI/state management, CLI parsing, Zalgo, and extensions.

<a id="monolib_dart-pillar-dart"></a>
### Pillar — Dependency Injection & State Management

- **Import:** `import 'package:monolib_dart/pillar.dart';`
- **Overview:** Scoped dependency injection and change notification utilities.

#### `typedef PillarFactory<T> = T Function(PillarAccessor);`

- **Source:** `monolib-dart/lib/src/pillar/pillar.dart`

A factory function signature for resolving a dependency using a [PillarAccessor].

Functions of this type are registered with [Pillar.register] to lazily
instantiate objects that require dependencies from the container.

---

#### `typedef PillarPureFactory<T> = T Function();`

- **Source:** `monolib-dart/lib/src/pillar/pillar.dart`

A factory function signature for instantiating a dependency without
accessing the dependency injection container.

Used for objects that have no dependencies in the container and can be
created independently of a [PillarAccessor].

---

#### `class Pillar implements PillarAccessor`

- **Source:** `monolib-dart/lib/src/pillar/pillar.dart`

The dependency injection container and scope lifecycle manager.

[Pillar] registers, caches, and resolves dependencies mapped by [PillarKey]
to [PillarEntry]. It implements [PillarAccessor] to expose a read-only
resolution interface while managing the underlying registry.

During resolution, [Pillar] uses [ScopeTrackingPillarAccessor] to record the
lowest [PillarScope] accessed by a factory and [ScopeEnforcingPillarAccessor]
to prevent longer-lived scoped entries from depending on shorter-lived ones.

Example:
```dart
final pillar = Pillar();
const globalScope = PillarScope.global();

// Register a singleton scoped globally
pillar.register<HttpClient>(
  factory: (accessor) => HttpClient(),
  scope: globalScope,
);

// Register a factory that injects the client
pillar.register<ApiService>(
  factory: (accessor) => ApiService(accessor.get<HttpClient>()),
);

// Resolve dependencies
final service = pillar.get<ApiService>();
```

##### Public Members

**Methods & Operators:**
- `T get<T>({PillarKey? key, String? token})` — Resolves and returns an instance of type [T] from the container.
- `void register<T>({ PillarKey? key, String? token, PillarFactory<T>? factory, PillarPureFactory<T>? pureFactory, T? instance, PillarScope? scope, })` — Registers a dependency into the Pillar framework.
- `void replace<T>({required T instance, required PillarScope scope})` — Directly substitutes an existing dependency with a specific [instance]
- `void discard(PillarScope scope)` — Invalidates and clears cached instances associated with the given [scope].
- `PillarListenable changeNotifierFor(PillarScope scope)` — Returns a [PillarListenable] that notifies listeners whenever [replace] is

---

#### `abstract class PillarAccessor`

- **Source:** `monolib-dart/lib/src/pillar/pillar_accessor.dart`

A read-only interface for retrieving registered dependencies from a `Pillar`
container.

[PillarAccessor] is passed to factory functions so they can resolve
transitive dependencies without exposing container mutation methods.
Implementations such as `ScopeTrackingPillarAccessor` and
`ScopeEnforcingPillarAccessor` track and validate `PillarScope` hierarchies
during resolution.

##### Public Members

**Methods & Operators:**
- `T get<T>({PillarKey? key, String? token})` — Resolves and returns an instance of type [T] from the container.

---

#### `extension OnPillarAccessor on PillarAccessor`

- **Source:** `monolib-dart/lib/src/pillar/pillar_accessor.dart`

Extension on [PillarAccessor] that supports assisted dependency injection.

##### Public Members

**Methods & Operators:**
- `T assisted<T, P>(P parameter, {PillarKey? key, String? token})` — Resolves a factory of type `T Function(P)` from the container and invokes

---

#### `class PillarChangeNotifier implements PillarListenable`

- **Source:** `monolib-dart/lib/src/pillar/pillar_change_notifier.dart`

A pure-Dart implementation of [PillarListenable] that dispatches synchronous
notifications when a `PillarScope` is updated.

Each notifier maintains a list of listener callbacks and is typically
obtained via `Pillar.changeNotifierFor` to observe when dependencies in a
scope are replaced. In Flutter applications, it can be adapted to a Flutter
`Listenable` using `PillarListenableAdapter` (via the `.asListenable`
extension getter).

Example:
```dart
final PillarListenable scopeNotifier = pillar.changeNotifierFor(myScope);

void onDependenciesUpdated() {
  print('The DI scope has been invalidated or updated!');
}

scopeNotifier.addListener(onDependenciesUpdated);
```

##### Public Members

**Methods & Operators:**
- `void addListener(void Function() listener)` — Registers [listener] to be called synchronously whenever [notifyListeners]
- `void removeListener(void Function() listener)` — Removes a previously registered [listener] from this notifier.
- `void notifyListeners()` — Synchronously invokes all registered listeners.
- `void dispose()` — Clears all registered listeners from this notifier.

---

#### `extension type const PillarKey._((`

- **Source:** `monolib-dart/lib/src/pillar/pillar_key.dart`

A composite lookup key used by `Pillar` to identify registered dependencies.

[PillarKey] pairs a Dart [Type] with an optional string [token], allowing
multiple registrations of the same type to be disambiguated by name.

Example:
```dart
// Type-only key
const defaultKey = PillarKey(Database);

// Tokenized key
const cacheKey = PillarKey.withToken(Database, token: 'cache');
```

---

#### `abstract class PillarListenable`

- **Source:** `monolib-dart/lib/src/pillar/pillar_listenable.dart`

An interface for objects that can be listened to for state or scope changes.

This provides a pure-Dart notification contract (analogous to Flutter's
`Listenable`) without requiring a dependency on Flutter.

Callers typically encounter this as the return type of `Pillar.changeNotifierFor`,
and implementations can use `PillarChangeNotifier` rather than implementing
this interface directly. In Flutter applications, instances can be adapted
using the `.asListenable` extension from `package:monolib_flutter`.

Example:
```dart
final PillarListenable listenable = pillar.changeNotifierFor(myScope);

void onScopeChanged() {
  print('Scope updated!');
}

listenable.addListener(onScopeChanged);
// Later:
listenable.removeListener(onScopeChanged);
```

##### Public Members

**Methods & Operators:**
- `void addListener(void Function() listener)` — Registers a [listener] callback to be invoked when the object changes.
- `void removeListener(void Function() listener)` — Unregisters a previously registered [listener] callback.

---

#### `class PillarScope`

- **Source:** `monolib-dart/lib/src/pillar/pillar_scope.dart`

Represents a hierarchical lifecycle boundary within the Pillar dependency injection framework.

A [PillarScope] dictates how long an instance lives and dictates dependency
resolution rules. It is primarily used to prevent a longer-lived object
(e.g., a global singleton) from holding onto a shorter-lived object (e.g.,
an active session), which would create a memory leak or stale state.

In practice, you declare scopes hierarchically. When an instance is
registered via `Pillar.register` with a specific scope, the framework tracks it.
If a lower-scoped instance (e.g., `userScope`) is requested by a higher-scoped
instance (e.g., `globalScope`), a scope enforcement exception is thrown.

Scopes also act as boundaries for invalidation. Calling `Pillar.discard` or
`Pillar.replace` with a [PillarScope] clears or replaces all cached instances
associated with that scope and its children, allowing developers to reset
states cleanly (e.g., upon user logout).

Example:
```dart
const PillarScope appScope = PillarScope.global();
final PillarScope sessionScope = appScope.child('session');

// Later, when replacing a dependency specifically for the session:
pillar.replace(instance: newSessionConfig, scope: sessionScope);
```

##### Public Members

**Constructors:**
- `const PillarScope.global()` — Creates a root-level global scope with the name 'global' and no parent.
- `const PillarScope({required this.name, required PillarScope this.parent})` — Creates a custom [PillarScope] with a specific [name] and [parent].

**Properties & Getters:**
- `final String name` — The descriptive name of this scope, primarily used for debugging and logging.
- `final PillarScope? parent` — The parent boundary of this scope, or `null` if this is the root.
- `int get hashCode` — Computes a hash code based on [name] and [parent].

**Methods & Operators:**
- `PillarScope child(String name)` — Derives a new, more restrictive child scope from `this` scope.
- `bool isOrChildOf(PillarScope scope)` — Checks if `this` scope is the same as, or a descendant of, the provided [scope].
- `bool operator ==(Object other)` — Compares this scope to [other] by comparing their names and parents.
- `String toString()` — Returns a string representation of the scope, useful for debugging errors.

---

#### `extension OnFunction1<T, P0> on T Function(P0)`

- **Source:** `monolib-dart/lib/src/pillar/to_pillar_factory.dart`

Extension on a 1-parameter function that adapts it into a `PillarFactory`.

The returned factory resolves the positional parameter [P0] from the
`Pillar` container via [PillarAccessor.get], allowing constructors or
functions to be registered without writing manual tear-off closures.

Example:
```dart
// Without toPillarFactory:
pillar.register<UserService>(
  factory: (accessor) => UserService(accessor.get<Database>()),
);

// With toPillarFactory:
pillar.register<UserService>(
  factory: UserService.new.toPillarFactory(),
);
```

##### Public Members

**Methods & Operators:**
- `T Function(PillarAccessor) toPillarFactory()` — Converts this function into a `PillarFactory` by resolving [P0] via

---

#### `extension OnFunction2<T, P0, P1> on T Function(P0, P1)`

- **Source:** `monolib-dart/lib/src/pillar/to_pillar_factory.dart`

Extension on a 2-parameter function that adapts it into a `PillarFactory`.

Example:
```dart
pillar.register<UserService>(
  factory: UserService.new.toPillarFactory(),
);
```

##### Public Members

**Methods & Operators:**
- `T Function(PillarAccessor) toPillarFactory()` — Converts this function into a `PillarFactory` by resolving [P0] and [P1]

---

#### `extension OnFunction3<T, P0, P1, P2> on T Function(P0, P1, P2)`

- **Source:** `monolib-dart/lib/src/pillar/to_pillar_factory.dart`

Extension on a 3-parameter function that adapts it into a `PillarFactory`.

##### Public Members

**Methods & Operators:**
- `T Function(PillarAccessor) toPillarFactory()` — Converts this function into a `PillarFactory` by resolving [P0] through

---

#### `extension OnFunction4<T, P0, P1, P2, P3> on T Function(P0, P1, P2, P3)`

- **Source:** `monolib-dart/lib/src/pillar/to_pillar_factory.dart`

Extension on a 4-parameter function that adapts it into a `PillarFactory`.

##### Public Members

**Methods & Operators:**
- `T Function(PillarAccessor) toPillarFactory()` — Converts this function into a `PillarFactory` by resolving [P0] through

---

#### `extension OnFunction5<T, P0, P1, P2, P3, P4> on T Function(P0, P1, P2, P3, P4)`

- **Source:** `monolib-dart/lib/src/pillar/to_pillar_factory.dart`

Extension on a 5-parameter function that adapts it into a `PillarFactory`.

##### Public Members

**Methods & Operators:**
- `T Function(PillarAccessor) toPillarFactory()` — Converts this function into a `PillarFactory` by resolving [P0] through

---

#### `extension OnFunction6<T, P0, P1, P2, P3, P4, P5> on T Function( P0, P1, P2, P3, P4, P5)`

- **Source:** `monolib-dart/lib/src/pillar/to_pillar_factory.dart`

Extension on a 6-parameter function that adapts it into a `PillarFactory`.

##### Public Members

**Methods & Operators:**
- `T Function(PillarAccessor) toPillarFactory()` — Converts this function into a `PillarFactory` by resolving [P0] through

---

#### `extension OnFunction7<T, P0, P1, P2, P3, P4, P5, P6> on T Function( P0, P1, P2, P3, P4, P5, P6)`

- **Source:** `monolib-dart/lib/src/pillar/to_pillar_factory.dart`

Extension on a 7-parameter function that adapts it into a `PillarFactory`.

##### Public Members

**Methods & Operators:**
- `T Function(PillarAccessor) toPillarFactory()` — Converts this function into a `PillarFactory` by resolving [P0] through

---

#### `extension OnFunction8<T, P0, P1, P2, P3, P4, P5, P6, P7> on T Function( P0, P1, P2, P3, P4, P5, P6, P7)`

- **Source:** `monolib-dart/lib/src/pillar/to_pillar_factory.dart`

Extension on an 8-parameter function that adapts it into a `PillarFactory`.

##### Public Members

**Methods & Operators:**
- `T Function(PillarAccessor) toPillarFactory()` — Converts this function into a `PillarFactory` by resolving [P0] through

---

#### `extension OnFunction9<T, P0, P1, P2, P3, P4, P5, P6, P7, P8> on T Function( P0, P1, P2, P3, P4, P5, P6, P7, P8)`

- **Source:** `monolib-dart/lib/src/pillar/to_pillar_factory.dart`

Extension on a 9-parameter function that adapts it into a `PillarFactory`.

##### Public Members

**Methods & Operators:**
- `T Function(PillarAccessor) toPillarFactory()` — Converts this function into a `PillarFactory` by resolving [P0] through

---

#### `extension OnFunction10<T, P0, P1, P2, P3, P4, P5, P6, P7, P8, P9> on T Function( P0, P1, P2, P3, P4, P5, P6, P7, P8, P9)`

- **Source:** `monolib-dart/lib/src/pillar/to_pillar_factory.dart`

Extension on a 10-parameter function that adapts it into a `PillarFactory`.

##### Public Members

**Methods & Operators:**
- `T Function(PillarAccessor) toPillarFactory()` — Converts this function into a `PillarFactory` by resolving [P0] through

---

<a id="monolib_dart-fluent_json-dart"></a>
### FluentJson — Dynamic JSON Navigation & Unboxing

- **Import:** `import 'package:monolib_dart/fluent_json.dart';`
- **Overview:** Fluent, null-safe navigation and extraction utilities for decoded JSON values.

#### `class FluentJson`

- **Source:** `monolib-dart/lib/src/json/fluent_json.dart`

A safe, path-tracked wrapper for traversing dynamic JSON structures.

[FluentJson] wraps decoded JSON values (such as those produced by
`dart:convert`) to simplify nested access and type-checked unboxing. It
maintains a path trail from the root node so that missing keys,
unexpected nulls, or type mismatches report the exact JSON path in the
thrown exception (for example, `Hierarchy from root json: $[users][0][id]`).

##### Public Members

**Constructors:**
- `const FluentJson({required this.json, List<dynamic> breadCrumbs = const []})` — Creates a [FluentJson] wrapping [json] with an optional path trail.
- `FluentJson.decode(String json)` — Instantiates a [FluentJson] root object by natively decoding the string payload.
- `const FluentJson.empty()` — Instantiates an empty [FluentJson] object wrapping a null value.
- `FluentJson.root(this.json)` — Instantiates a [FluentJson] root from existing mapped [json], starting the path trail.

**Properties & Getters:**
- `final dynamic json` — The dynamic, untyped JSON payload wrapped at this hierarchy level.

**Methods & Operators:**
- `FluentJson? elementAt(dynamic accessor)` — Safely attempts to traverse into a child node using a key or index [accessor].
- `FluentJson operator [](dynamic accessor)` — Traverses into a child node using a key or index [accessor], strictly expecting
- `FluentJson cascading(List<dynamic> accessors)` — Sequentially traverses through a provided list of [accessors] to fetch deeply
- `T unbox<T>()` — Casts the raw wrapped [json] to the designated target type [T].
- `T unboxed<T>(dynamic accessor)` — Traverses into a child using [accessor] and immediately casts its value
- `T? unboxedElementAt<T>(dynamic accessor)` — Safely traverses into an optional child using [accessor] and casts it to [T].
- `Iterable<FluentJson> unboxIterable() sync*` — Interprets the current structure as a JSON array and iterates over its items.
- `List<T> unboxMappedList<T>(T Function(FluentJson) mapper)` — Maps an array of JSON objects to a strongly-typed Dart [List] using a closure.

---

#### `extension OnFluentJson on FluentJson`

- **Source:** `monolib-dart/lib/src/json/on_fluent_json.dart`

Extension on [FluentJson] that provides type-safe conversion getters for
domain types.

Example:
```dart
final jsonStr = '{"event": "login", "timestamp": "2023-10-15T13:45:30.000Z"}';
final json = jsonStr.parseAsFluentJson();

final loginTime = json['timestamp'].asDateTime;
```

##### Public Members

**Properties & Getters:**
- `DateTime get asDateTime` — Unboxes the underlying JSON value as a [String] and parses it into a [DateTime].

---

#### `extension OnString on String`

- **Source:** `monolib-dart/lib/src/json/on_string.dart`

Extension on [String] that parses JSON strings directly into [FluentJson]
instances.

##### Public Members

**Methods & Operators:**
- `FluentJson parseAsFluentJson()` — Parses this [String] as JSON and wraps the decoded value in a root

---

<a id="monolib_dart-json_encode_async-dart"></a>
### Async JSON — Non-blocking Streaming JSON Serialization

- **Import:** `import 'package:monolib_dart/json_encode_async.dart';`
- **Overview:** Asynchronous and streaming JSON serialization utilities.

#### `typedef JsonEncoderCallback = Future<void> Function(Object? object);`

- **Source:** `monolib-dart/lib/src/json/async_json_writable.dart`

A callback passed into [AsyncJsonWritable.writeJsonAsync] that allows an
object to recursively serialize nested values back into the active
`jsonEncodeAsync` context.

When called with an [object], this function encodes it using the same
asynchronous rules and formatting as the root `jsonEncodeAsync` invocation,
appending the resulting JSON chunks to the active [StringSink].

---

#### `abstract class AsyncJsonWritable`

- **Source:** `monolib-dart/lib/src/json/async_json_writable.dart`

A contract for objects that write their JSON representation directly to a
[StringSink] during `jsonEncodeAsync`.

Implementing [AsyncJsonWritable] bypasses standard `toJson()` serialization
and grants direct access to the target [StringSink]. This allows large or
streaming payloads (such as `StreamingJsonString`) to be written
progressively without buffering the entire structure in memory.

Example:
```dart
class MyLazyArray implements AsyncJsonWritable {
  final Stream<int> _numbers;
  MyLazyArray(this._numbers);

  @override
  Future<void> writeJsonAsync(StringSink sink, JsonEncoderCallback encode) async {
    sink.write('[');
    bool first = true;
    await for (final number in _numbers) {
      if (!first) sink.write(',');
      await encode(number);
      first = false;
    }
    sink.write(']');
  }
}
```

##### Public Members

**Methods & Operators:**
- `Future<void> writeJsonAsync(StringSink sink, JsonEncoderCallback encode)` — Writes the raw JSON representation of this object directly to [sink].

---

#### `Future<void> jsonEncodeAsync(`

- **Source:** `monolib-dart/lib/src/json/json_encode_async.dart`

Asynchronously encodes an [object] into JSON and writes it to a [StringSink]
in chunks.

Unlike standard [jsonEncode], this function resolves nested [Future]s and
progressively consumes [Stream]s, writing array items or object values as
they arrive without buffering the full JSON tree in memory.

Sink initialization and lifecycle management are delegated to
[withLazyStringSink]. Exactly one of [sink] or [sinkProvider] must be
provided, or an [ArgumentError] is thrown.

- [object]: The root object to serialize. Supports primitives, [Map]s,
  [Iterable]s, awaited [Future]s, streamed [Stream]s, objects implementing
  `toJson()`, and [AsyncJsonWritable] instances.
- [sink]: An active, externally managed [StringSink]. If provided, the
  caller retains ownership and is responsible for closing it.
- [sinkProvider]: A factory callback that lazily creates a [StringSink] when
  the first output is ready to be written. The created sink is closed
  automatically upon completion or error if it implements [Sink] or
  [StreamSink].

Example:
```dart
final stream = Stream.fromIterable([1, 2, 3]);
final lazyData = {
  'meta': 'chunked',
  'values': stream,
};

final buffer = StringBuffer();
await jsonEncodeAsync(object: lazyData, sink: buffer);
print(buffer.toString()); // {"meta":"chunked","values":[1,2,3]}
```

---

#### `class LazyJson`

- **Source:** `monolib-dart/lib/src/json/lazy_json.dart`

A wrapper that defers computing a JSON-serializable value until it is
serialized.

Wrapping a computation in [LazyJson] delays evaluation until a serializer
such as `jsonEncode` or `jsonEncodeAsync` invokes [toJson].

Example:
```dart
final payload = LazyJson(() {
  // This mapping logic runs only when jsonEncode() is called.
  return {'timestamp': DateTime.now().toIso8601String(), 'data': 'massive'};
});

final jsonString = jsonEncode(payload);
```

##### Public Members

**Constructors:**
- `const LazyJson(this.toJson)` — Creates a [LazyJson] that executes [toJson] when serialized.

**Methods & Operators:**
- `final dynamic Function() toJson` — The deferred callback that returns the JSON-serializable value.

---

#### `class StreamingJsonString implements AsyncJsonWritable`

- **Source:** `monolib-dart/lib/src/json/streaming_json_string.dart`

An [AsyncJsonWritable] that streams a [Stream] of strings directly into an
active JSON sink as a single, properly escaped JSON string literal.

Instead of buffering a large string in memory via a synchronous `toJson()`
call, [StreamingJsonString] listens to the stream returned by
[streamProvider] and writes escaped chunks progressively to the target
[StringSink].

Example:
```dart
final jsonObject = {
  'filename': 'massive_log.txt',
  'content': StreamingJsonString(
    () => File('massive_log.txt').openRead().transform(utf8.decoder),
  ),
};

await jsonEncodeAsync(object: jsonObject, sink: stdout);
```

##### Public Members

**Constructors:**
- `const StreamingJsonString(Stream<String> Function() streamProvider)` — Creates a [StreamingJsonString] that incrementally encodes and writes

**Methods & Operators:**
- `Future<void> writeJsonAsync( StringSink sink, JsonEncoderCallback encode, ) async` — Asynchronously reads chunks from the underlying stream provider, escapes

---

<a id="monolib_dart-stream-dart"></a>
### Reactive Streams — Stream/Sink Extensions & Composite Event Sinks

- **Import:** `import 'package:monolib_dart/stream.dart';`
- **Overview:** Stream, sink, and stream controller extensions and composite utilities.

#### `class CompositeEventSink<T> implements EventSink<T>`

- **Source:** `monolib-dart/lib/src/stream/composite_event_sink.dart`

An [EventSink] that forwards all events to multiple child [EventSink]s.

[CompositeEventSink] distributes [add], [addError], and [close] calls across
a collection of downstream sinks. If a child sink throws a synchronous
exception during dispatch, handling is delegated to the configured
[ExceptionStrategy] (for example, failing immediately, ignoring errors, or
collecting multiple errors into a `CompositeSinkException`).

Example:
```dart
final sink1 = StreamController<int>();
final sink2 = StreamController<int>();
final compositeSink = CompositeEventSink([sink1.sink, sink2.sink]);

compositeSink.add(42); // Forwards 42 to both sink1 and sink2.
compositeSink.close(); // Closes both sink1 and sink2.
```

##### Public Members

**Constructors:**
- `CompositeEventSink( Iterable<EventSink<T>> sinks, { bool throwOnClosed = false, ExceptionStrategy exceptionStrategy = ExceptionStrategy.failFast, })` — Creates a [CompositeEventSink] that forwards events to [sinks].

**Methods & Operators:**
- `void add(T data)` — Forwards [data] to all child sinks.
- `void close()` — Closes this composite sink and forwards [close] to all child sinks.
- `void addError(Object error, [StackTrace? stackTrace])` — Forwards [error] and optional [stackTrace] to all child sinks.

---

#### `class CompositeSinkException implements Exception`

- **Source:** `monolib-dart/lib/src/stream/composite_event_sink/composite_sink_exception.dart`

An exception that aggregates multiple errors thrown while dispatching an
event across multiple sinks.

Thrown by [ExceptionStrategy.aggregate] (for example, in a
`CompositeEventSink`) when two or more child sinks throw synchronous
exceptions during the same dispatch pass. If only a single sink fails,
[ExceptionStrategy.aggregate] rethrows that original exception directly.

Example:
```dart
final sink1 = StreamController<int>()..close();
final sink2 = StreamController<int>();
final sink3 = StreamController<int>()..close();

final compositeSink = CompositeEventSink<int>(
  [sink1.sink, sink2.sink, sink3.sink],
  exceptionStrategy: ExceptionStrategy.aggregate,
);

try {
  compositeSink.add(42);
} on CompositeSinkException catch (e) {
  print('Failed to notify all sinks. Errors: ${e.errors}');
}
```

##### Public Members

**Constructors:**
- `CompositeSinkException(this.errors)` — Creates a [CompositeSinkException] wrapping the collected [errors].

**Properties & Getters:**
- `final List<Object> errors` — The exceptions caught from failing child sinks during dispatch.

**Methods & Operators:**
- `String toString()`

---

#### `abstract class ExceptionStrategy`

- **Source:** `monolib-dart/lib/src/stream/composite_event_sink/exception_strategy.dart`

A strategy for handling synchronous exceptions thrown while dispatching an
operation across multiple [EventSink]s.

When an event is forwarded to multiple sinks (such as in a
`CompositeEventSink`), individual sinks may throw synchronous exceptions
(for example, if a sink is already closed). Implementations of
[ExceptionStrategy] determine whether dispatch halts on the first error
([failFast]), ignores errors ([swallow]), or collects errors after
notifying all sinks ([aggregate]).

Custom strategies can be created by implementing [ExceptionStrategy].

Example:
```dart
final compositeSink = CompositeEventSink(
  [localDbSink, remoteApiSink],
  exceptionStrategy: ExceptionStrategy.aggregate,
);

try {
  compositeSink.add(myData);
} on CompositeSinkException catch (e) {
  print('Some destinations failed: ${e.errors}');
}
```

##### Public Members

**Constructors:**
- `const ExceptionStrategy()` — Creates an [ExceptionStrategy].

**Methods & Operators:**
- `void dispatch<T>( Iterable<EventSink<T>> sinks, void Function(EventSink<T> sink) action, )` — Executes [action] on each sink in [sinks] using this strategy's

---

#### `extension FutureEventSinkExtension<T> on Future<EventSink<T>>`

- **Source:** `monolib-dart/lib/src/stream/future_event_sink_extension.dart`

Extension on [Future] of [EventSink] that exposes a synchronous proxy
[EventSink] while the underlying sink is still initializing.

##### Public Members

**Methods & Operators:**
- `EventSink<T> unwrap()` — Unwraps this [Future] into a synchronous proxy [EventSink] that buffers

---

#### `class LineSplitterConverter extends Converter<String, String>`

- **Source:** `monolib-dart/lib/src/stream/line_splitter_converter.dart`

A [Converter] adapter around Dart's [LineSplitter] for chunked string
conversion.

Because [LineSplitter] is a `StreamTransformer` rather than a [Converter],
it cannot be passed directly to [Converter.fuse]. [LineSplitterConverter]
wraps [LineSplitter.startChunkedConversion] as a [Converter] so it can be
fused with other converters such as `utf8.decoder` (see
[OnStreamOfListOfInt.utf8DecodeAndLineSplit]).

Example:
```dart
final fusedConverter = utf8.decoder.fuse(const LineSplitterConverter());
final lineStream = File('data.csv').openRead().transform(fusedConverter);
```

##### Public Members

**Constructors:**
- `const LineSplitterConverter()` — Creates a constant [LineSplitterConverter].

**Methods & Operators:**
- `String convert(String input)` — Always throws an [UnsupportedError] because this converter only supports
- `Sink<String> startChunkedConversion(Sink<String> sink)` — Starts a chunked conversion that splits incoming string chunks into

---

#### `extension MapNotNullStreamExtension<T> on Stream<T>`

- **Source:** `monolib-dart/lib/src/stream/map_not_null_stream_extension.dart`

Extension on [Stream] that combines mapping and null-filtering into a
single transformation.

##### Public Members

**Methods & Operators:**
- `Stream<R> mapNotNull<R>(R? Function(T event) mapper)` — Transforms each event in this stream by applying [mapper] and emitting

---

#### `extension OnEventSink<T> on EventSink<T>`

- **Source:** `monolib-dart/lib/src/stream/on_event_sink.dart`

Extension on [EventSink] that provides [tryAddError] for safely adding
errors without throwing a [StateError] when the sink is closed.

##### Public Members

**Methods & Operators:**
- `void tryAddError( Object error, { StackTrace? stackTrace, bool ignoreError = false, void Function(Object error, StackTrace stackTrace)? onError, })` — Adds [error] (and optional [stackTrace]) to this sink if it is still open,

---

#### `extension OnIterableOfStreamControllers<T> on Iterable<StreamController<T>>`

- **Source:** `monolib-dart/lib/src/stream/on_iterable_of_stream_controllers.dart`

Extension on [Iterable] of [StreamController] that broadcasts data and error
events across all controllers using a configurable [ExceptionStrategy].

##### Public Members

**Methods & Operators:**
- `void onEachAdd( T event, { ExceptionStrategy strategy = ExceptionStrategy.swallow, })` — Dispatches [event] to every [StreamController] in this iterable.
- `void onEachAddError( Object error, [ StackTrace? stackTrace, ExceptionStrategy strategy = ExceptionStrategy.swallow, ])` — Dispatches [error] and optional [stackTrace] to every [StreamController]

---

#### `extension OnListOfStreamControllers<T> on List<StreamController<T>>`

- **Source:** `monolib-dart/lib/src/stream/on_list_of_stream_controllers.dart`

Extension on [List] of [StreamController] that automatically removes
controllers when their subscriptions are cancelled.

##### Public Members

**Methods & Operators:**
- `void addAndSetupOnCancel( StreamController<T> listener, { void Function()? onEmpty, Function? onRemoveError, })` — Adds [listener] to this list and configures its

---

#### `extension OnSink<T> on Sink<T>`

- **Source:** `monolib-dart/lib/src/stream/on_sink.dart`

Extension on [Sink] that provides [tryAdd] for safely adding events without
throwing a [StateError] when the sink is closed.

##### Public Members

**Methods & Operators:**
- `void tryAdd( T event, { bool ignoreError = false, void Function(Object error, StackTrace stackTrace)? onError, })` — Adds [event] to this sink if it is still open, ignoring any [StateError]

---

#### `extension OnStream<T> on Stream<T>`

- **Source:** `monolib-dart/lib/src/stream/on_stream.dart`

Extension on [Stream] that provides null-safe terminal operations for
retrieving the last emitted element.

##### Public Members

**Properties & Getters:**
- `Future<T?> get lastOrNull` — Completes with the last element emitted by this stream, or `null` if the

**Methods & Operators:**
- `Future<R?> mappedLastOrNull<R>(R? Function(T) mapper)` — Completes with the last non-null value returned by [mapper] for elements

---

#### `extension OnStreamOfListOfInt on Stream<List<int>>`

- **Source:** `monolib-dart/lib/src/stream/on_stream_of_list_of_int.dart`

Extension on byte streams (`Stream<List<int>>`) for UTF-8 decoding and line
splitting.

##### Public Members

**Methods & Operators:**
- `Future<String> readLine()` — Decodes this byte stream as UTF-8, splits it into lines, and returns the
- `Stream<String> utf8DecodeAndLineSplit()` — Decodes this byte stream as UTF-8 and splits it into individual text

---

#### `extension OnStreamOfLists<T> on Stream<List<T>>`

- **Source:** `monolib-dart/lib/src/stream/on_stream_of_lists.dart`

Extension on [Stream] of [List] that provides flattening, accumulation,
batch mapping, and element filtering utilities.

##### Public Members

**Methods & Operators:**
- `Future<List<T>> flattenToList({ bool cancelOnError = true, bool sync = false, })` — Collects all lists emitted by this stream into a single flattened [List].
- `Stream<List<T>> asAccumulating({bool emptyMeansRefresh = false})` — Transforms this stream to emit a cumulatively growing list containing all
- `Stream<List<R>> mapLists<R>( List<R> Function(List<T>) mapper, { bool skipMappedToEmpty = true, })` — Transforms each non-empty list chunk emitted by this stream using
- `Stream<List<T>> whereElements( bool Function(T)? predicate, { bool skipMappedToEmpty = true, })` — Filters elements in each emitted list in place using [predicate].

---

#### `class SingleValueCachingStream<T> extends Stream<T>`

- **Source:** `monolib-dart/lib/src/stream/single_value_caching_stream.dart`

A broadcast [Stream] that caches a single synchronous [value] and emits it
to each new listener before closing.

Because [isBroadcast] is `true`, multiple listeners can subscribe
independently and each will receive [value] followed by a done event.

Example:
```dart
Stream<String> getGreetingStream() {
  return const SingleValueCachingStream('Hello, World!');
}

final stream = getGreetingStream();
stream.listen(print); // Prints: Hello, World!
stream.listen(print); // Prints: Hello, World!
```

##### Public Members

**Constructors:**
- `const SingleValueCachingStream(T value)` — Creates a broadcast stream that emits [value] to each listener.

**Properties & Getters:**
- `bool get isBroadcast` — Whether this stream is a broadcast stream (always `true`).

**Methods & Operators:**
- `StreamSubscription<T> listen( void Function(T event)? onData, { Function? onError, void Function()? onDone, bool? cancelOnError, })` — Subscribes to this stream and asynchronously emits the cached [value]

---

#### `extension StreamWhereTypeExtension<T> on Stream<T>`

- **Source:** `monolib-dart/lib/src/stream/stream_where_type_extension.dart`

Extension on [Stream] that filters and casts events by runtime type in a
single pass.

##### Public Members

**Methods & Operators:**
- `Stream<R> whereType<R>()` — Filters this stream to emit only elements that are instances of [R],

---

#### `extension type const StreamWithClose<T>._( (`

- **Source:** `monolib-dart/lib/src/stream/stream_with_close.dart`

A wrapper that pairs a [Stream] with the [StreamSubscription]s and
[StreamController] backing it so they can be closed together.

Calling [close] cancels all underlying subscriptions and closes the
controller in a single operation.

Example:
```dart
StreamWithClose<int> createPolledStream() {
  final controller = StreamController<int>();
  final timerSub = Stream.periodic(const Duration(seconds: 1)).listen((i) {
    controller.add(i);
  });

  return StreamWithClose(
    stream: controller.stream,
    subscriptions: [timerSub],
    controller: controller,
  );
}

final closable = createPolledStream();
// ... consume closable.stream ...
await closable.close(); // Cancels timerSub and closes controller
```

---

<a id="monolib_dart-csv-dart"></a>
### CSV — Streaming CSV Encoders, Decoders & Batchers

- **Import:** `import 'package:monolib_dart/csv.dart';`
- **Overview:** Streaming and synchronous CSV encoding and decoding utilities.

#### `class CsvChunkedDecoder extends ChunkedOnlyConverter<String, List<String>>`

- **Source:** `monolib-dart/lib/src/csv/csv_chunked_decoder.dart`

A streaming converter that parses chunked RFC 4180 CSV string data into
rows of string cells (`List<String>`).

[CsvChunkedDecoder] extends [ChunkedOnlyConverter] and delegates stateful
CSV row and field parsing to [CsvBaseChunkSink]. It transforms asynchronous
`Stream<String>` pipelines directly into streams of `List<String>` rows and
also underpins synchronous converters such as `CsvDecoder`.

Example:
```dart
final rowStream = File('data.csv')
    .openRead()
    .transform(utf8.decoder)
    .transform(const CsvChunkedDecoder());

await for (final row in rowStream) {
  print(row);
}
```

##### Public Members

**Constructors:**
- `const CsvChunkedDecoder()` — Creates a [CsvChunkedDecoder].

**Methods & Operators:**
- `Sink<String> startChunkedConversion(Sink<List<String>> sink)` — Starts a chunked conversion that parses incoming CSV string chunks and

---

#### `class CsvCodec extends Codec<List<dynamic>, String>`

- **Source:** `monolib-dart/lib/src/csv/csv_codec.dart`

A [Codec] that encodes and decodes RFC 4180 Comma-Separated Values (CSV) strings.

[CsvCodec] provides bidirectional conversion between a list of rows and an
RFC 4180 CSV-formatted [String] by delegating to [CsvEncoder] and
[CsvDecoder].

When encoding, it converts a [List] of rows (where each row is either a
[List] of cell values or an object implementing `toCsv()`) into a
`\r\n`-delimited CSV [String]. When decoding, it parses a CSV [String] into
a `List<List<String>>` of rows and cells.

Example:
```dart
const codec = CsvCodec();

// Encoding
final csvString = codec.encode([
  ['id', 'name'],
  [1, 'Alice'],
  [2, 'Bob, Jr.'],
]);
// Result: 'id,name\r\n1,Alice\r\n2,"Bob, Jr."\r\n'

// Decoding
final rows = codec.decode(csvString);
// Result: [['id', 'name'], ['1', 'Alice'], ['2', 'Bob, Jr.']]
```

##### Public Members

**Constructors:**
- `const CsvCodec()` — Creates a [CsvCodec] for encoding and decoding CSV strings.

**Properties & Getters:**
- `Converter<List<dynamic>, String> get encoder` — Returns a [CsvEncoder] that converts a list of rows into a CSV [String].
- `Converter<String, List<List<String>>> get decoder` — Returns a [CsvDecoder] that parses a CSV [String] into a list of rows.

---

#### `class CsvDecoder extends Converter<String, List<List<String>>>`

- **Source:** `monolib-dart/lib/src/csv/csv_decoder.dart`

A synchronous [Converter] that decodes an RFC 4180 CSV [String] into a
list of rows, where each row is a `List<String>` of cells.

[CsvDecoder] serves as the synchronous decoder for `CsvCodec.decoder`. It
delegates parsing to [CsvChunkedDecoder] and collects all emitted rows in
memory using a [ListAccumulatorSink].

Because it buffers the entire result set in memory before returning, use
the stream-based [CsvChunkedDecoder] instead when processing large files or
streams.

Example:
```dart
const decoder = CsvDecoder();
final rows = decoder.convert('id,name\n1,"Alice"');
print(rows); // [['id', 'name'], ['1', 'Alice']]
```

##### Public Members

**Constructors:**
- `const CsvDecoder()` — Creates a [CsvDecoder].

**Methods & Operators:**
- `List<List<String>> convert(String items)` — Synchronously decodes the CSV string [items] into a list of parsed rows.

---

#### `Future<void> csvEncodeAsync(`

- **Source:** `monolib-dart/lib/src/csv/csv_encode_async.dart`

Asynchronously encodes a sequence of [items] into RFC 4180 CSV format and
writes each row to a destination [StringSink].

Accepts both [Iterable] and [Stream] collections via [iterateStreamOrIterable]
and dynamically resolves [Future] values at the row, `toCsv()`, and cell
levels. Each row is formatted as comma-separated cells escaped with
[writeCsvCell] and terminated by `\r\n`.

Sink initialization and lifecycle management are delegated to
[withLazyStringSink]. Exactly one of [sink] or [sinkProvider] must be
provided, or an [ArgumentError] is thrown.

- [items]: The [Iterable] or [Stream] of rows to encode. Each item (or
  awaited [Future]) must be a [List] of cells or an object implementing a
  `toCsv()` method that returns a [List] (or `Future<List>`), otherwise an
  [Exception] is thrown.
- [sink]: An active, externally managed [StringSink]. If provided, the
  caller retains ownership and is responsible for closing it.
- [sinkProvider]: A factory callback that lazily creates a [StringSink] when
  the first row is ready to be written (preventing empty files when [items]
  yields no elements). The created sink is closed automatically upon
  completion or error if it implements [Sink] or [StreamSink].

Example:
```dart
final buffer = StringBuffer();
final stream = Stream.fromIterable([
  ['Alice', 30],
  ['Bob', 25],
  Future.value(['Charlie', 40]),
]);

await csvEncodeAsync(
  items: stream,
  sink: buffer,
);
print(buffer.toString());
// Result: 'Alice,30\r\nBob,25\r\nCharlie,40\r\n'
```

---

#### `Future<void> csvEncodeBatchAsync<T>(`

- **Source:** `monolib-dart/lib/src/csv/csv_encode_batch_async.dart`

Asynchronously encodes a stream of [batches] into RFC 4180 CSV format and
writes each row to a destination [StringSink].

Delegates batch traversal and lazy sink management to [encodeBatchAsync],
encoding each non-empty batch with [csvEncodeAsync]. Exactly one of [sink]
or [sinkProvider] must be provided, or an [ArgumentError] is thrown.

- [batches]: The [Stream] of item batches (`List<T>`) to encode. Each item
  of type [T] must be a [List] representing a row, an object implementing
  `toCsv()` that returns a [List], or a [Future] resolving to one of those.
- [sink]: An active, externally managed [StringSink]. If provided, the
  caller retains ownership and is responsible for closing it.
- [sinkProvider]: A factory callback that lazily creates a [StringSink] when
  the first non-empty batch arrives (preventing empty files when [batches]
  yields no items). The created sink is closed automatically upon completion
  or error if it implements [Sink] or [StreamSink].

Example:
```dart
final batchesStream = Stream.fromIterable([
  [['Name', 'Age'], ['Alice', 30]],
  [['Bob', 25]],
]);
final buffer = StringBuffer();

await csvEncodeBatchAsync(
  batches: batchesStream,
  sink: buffer,
);
print(buffer.toString());
// Result: 'Name,Age\r\nAlice,30\r\nBob,25\r\n'
```

---

#### `class CsvEncoder extends Converter<List<dynamic>, String>`

- **Source:** `monolib-dart/lib/src/csv/csv_encoder.dart`

A synchronous [Converter] that encodes a list of rows into an RFC 4180
Comma-Separated Values (CSV) [String].

[CsvEncoder] serves as the synchronous encoder for `CsvCodec.encoder`. It
formats a list of rows into comma-separated cells terminated by `\r\n`.
Each row element in the input [List] must be either a [List] of cell values
or an object implementing a `toCsv()` method that returns a [List].

Because it buffers the entire output string in memory, use `csvEncodeAsync`
instead when streaming large datasets.

Example:
```dart
class User {
  final int id;
  final String name;
  User(this.id, this.name);

  List<dynamic> toCsv() => [id, name];
}

const encoder = CsvEncoder();
final csvData = encoder.convert([
  ['id', 'name'],
  User(1, 'Alice'),
  User(2, 'Bob, Jr.'),
]);
// Result: 'id,name\r\n1,Alice\r\n2,"Bob, Jr."\r\n'
```

##### Public Members

**Constructors:**
- `const CsvEncoder()` — Creates a [CsvEncoder].

**Methods & Operators:**
- `String convert(List<dynamic> items)` — Synchronously encodes [items] into an RFC 4180 CSV [String].

---

#### `class CsvMappedBatchDecoder<T> extends ChunkedOnlyConverter<String, List<T>>`

- **Source:** `monolib-dart/lib/src/csv/csv_mapped_batch_decoder.dart`

A streaming converter that parses chunked RFC 4180 CSV string data, maps
each parsed row into a domain object of type [T], and emits mapped items in
per-chunk batches (`List<T>`).

[CsvMappedBatchDecoder] extends [ChunkedOnlyConverter] and combines
[CsvBaseChunkSink] with [BatchingSinkMixin]. Each parsed row is passed to
[mapper]; non-null results are accumulated and flushed as a single
`List<T>` batch at the end of each input chunk, reducing stream event
overhead on high-volume CSV streams.

For one-by-one emission of mapped items, see [CsvMappedDecoder].

Example:
```dart
final fileStream = File('large_data.csv').openRead().transform(utf8.decoder);

final batchStream = fileStream.transform(
  CsvMappedBatchDecoder<User>((row) {
    if (row.isEmpty || row[0] == 'id') return null;
    return User(id: int.parse(row[0]), name: row[1]);
  }),
);

await for (final batch in batchStream) {
  await insertUsersToDatabase(batch);
}
```

##### Public Members

**Constructors:**
- `const CsvMappedBatchDecoder( T? Function(List<String> row) mapper, { void Function(List<T> batch)? onBatch, void Function()? onDone, })` — Creates a [CsvMappedBatchDecoder] that maps parsed CSV rows using [mapper]

**Methods & Operators:**
- `Sink<String> startChunkedConversion(Sink<List<T>> sink)` — Starts a chunked conversion that parses incoming CSV string chunks, maps

---

#### `class CsvMappedDecoder<T> extends ChunkedOnlyConverter<String, T>`

- **Source:** `monolib-dart/lib/src/csv/csv_mapped_decoder.dart`

A streaming converter that parses chunked RFC 4180 CSV string data and maps
each parsed row into a domain object of type [T].

[CsvMappedDecoder] extends [ChunkedOnlyConverter] and uses [CsvBaseChunkSink]
to split incoming string chunks into `List<String>` rows. Each row is passed
to [mapper]; non-null results are emitted individually downstream, while
`null` results are skipped.

For batched emission of mapped items per chunk, see [CsvMappedBatchDecoder].

Example:
```dart
final fileStream = File('users.csv').openRead().transform(utf8.decoder);

final userStream = fileStream.transform(
  CsvMappedDecoder<User>((row) {
    if (row.isEmpty || row[0] == 'id') return null;
    return User(id: int.parse(row[0]), name: row[1]);
  }),
);

await for (final user in userStream) {
  print(user.name);
}
```

##### Public Members

**Constructors:**
- `const CsvMappedDecoder( T? Function(List<String> row) mapper, { void Function()? onDone, })` — Creates a [CsvMappedDecoder] that maps parsed CSV rows using [mapper].

**Methods & Operators:**
- `Sink<String> startChunkedConversion(Sink<T> sink)` — Starts a chunked conversion that parses incoming CSV string chunks, maps

---

<a id="monolib_dart-jsonl-dart"></a>
### JSONL — Streaming JSON Lines Encoders, Decoders & Batchers

- **Import:** `import 'package:monolib_dart/jsonl.dart';`
- **Overview:** Streaming and synchronous JSON Lines (JSONL) encoding and decoding utilities.

#### `class JsonlChunkedDecoder extends ChunkedOnlyConverter<String, dynamic>`

- **Source:** `monolib-dart/lib/src/jsonl/jsonl_chunked_decoder.dart`

A streaming converter that parses chunked JSON Lines (JSONL) string data
into decoded JSON objects.

[JsonlChunkedDecoder] extends [ChunkedOnlyConverter] and delegates stateful
line boundary scanning to [JsonlBaseChunkSink]. It transforms asynchronous
`Stream<String>` pipelines directly into streams of decoded JSON values and
also underpins synchronous converters such as `JsonlDecoder`.

Empty lines and lines that decode to `null` are skipped.

Example:
```dart
final jsonStream = File('data.jsonl')
    .openRead()
    .transform(utf8.decoder)
    .transform(const JsonlChunkedDecoder());

await for (final jsonObject in jsonStream) {
  print(jsonObject['id']);
}
```

##### Public Members

**Constructors:**
- `const JsonlChunkedDecoder( {Codec<Object?, String> jsonCodec = const JsonCodec()})` — Creates a [JsonlChunkedDecoder].

**Methods & Operators:**
- `Sink<String> startChunkedConversion(Sink<dynamic> sink)` — Starts a chunked conversion that parses incoming JSONL string chunks and

---

#### `class JsonlCodec extends Codec<List<dynamic>, String>`

- **Source:** `monolib-dart/lib/src/jsonl/jsonl_codec.dart`

A [Codec] that encodes and decodes JSON Lines (JSONL) strings.

[JsonlCodec] provides bidirectional conversion between a list of
JSON-serializable objects and a newline-delimited JSONL [String] by
delegating to [JsonlEncoder] and [JsonlDecoder].

When encoding, it serializes each element in a [List] to a single-line JSON
string terminated by `\n`. When decoding, it splits a JSONL [String] into
lines, skips blank lines, and parses each line into a `List<dynamic>`.

Example:
```dart
const codec = JsonlCodec();

// Encoding
final jsonlString = codec.encode([
  {'id': 1, 'name': 'Alice'},
  {'id': 2, 'name': 'Bob'},
]);
// Result: '{"id":1,"name":"Alice"}\n{"id":2,"name":"Bob"}\n'

// Decoding
final objects = codec.decode(jsonlString);
// Result: [{'id': 1, 'name': 'Alice'}, {'id': 2, 'name': 'Bob'}]
```

##### Public Members

**Constructors:**
- `const JsonlCodec({Codec<Object?, String> jsonCodec = const JsonCodec()})` — Creates a [JsonlCodec] for encoding and decoding JSONL strings.

**Properties & Getters:**
- `Converter<String, List<dynamic>> get decoder` — Returns a [JsonlDecoder] configured with [_jsonCodec] that parses a JSONL
- `Converter<List<dynamic>, String> get encoder` — Returns a [JsonlEncoder] configured with [_jsonCodec] that converts a list

---

#### `class JsonlDecoder extends Converter<String, List<dynamic>>`

- **Source:** `monolib-dart/lib/src/jsonl/jsonl_decoder.dart`

A synchronous [Converter] that decodes a JSON Lines (JSONL) [String] into a
`List<dynamic>` of decoded JSON objects.

[JsonlDecoder] serves as the synchronous decoder for `JsonlCodec.decoder`.
It delegates parsing to [JsonlChunkedDecoder] and collects all emitted JSON
objects in memory using a [ListAccumulatorSink].

Because it buffers the entire result set in memory before returning, use
the stream-based [JsonlChunkedDecoder] instead when processing large files
or streams.

Example:
```dart
const decoder = JsonlDecoder(JsonCodec());
final objects = decoder.convert('{"name":"Alice"}\n{"name":"Bob"}\n');
print(objects); // [{'name': 'Alice'}, {'name': 'Bob'}]
```

##### Public Members

**Constructors:**
- `const JsonlDecoder(Codec<Object?, String> jsonCodec)` — Creates a [JsonlDecoder] configured with [jsonCodec].

**Methods & Operators:**
- `List<dynamic> convert(String items)` — Synchronously decodes the JSONL string [items] into a list of parsed JSON objects.

---

#### `Future<void> jsonlEncodeAsync(`

- **Source:** `monolib-dart/lib/src/jsonl/jsonl_encode_async.dart`

Asynchronously encodes a sequence of [items] into JSON Lines (JSONL) format
and writes each line to a destination [StringSink].

Accepts both [Iterable] and [Stream] collections via [iterateStreamOrIterable]
and encodes each item using [jsonEncodeAsync], followed by a trailing
newline (`\n`).

Sink initialization and lifecycle management are delegated to
[withLazyStringSink]. Exactly one of [sink] or [sinkProvider] must be
provided, or an [ArgumentError] is thrown.

- [items]: The [Iterable] or [Stream] of items to encode. Each item is
  serialized via [jsonEncodeAsync], which supports nested [Future],
  [Stream], and [Iterable] values, `toJson()` methods, and
  `AsyncJsonWritable` objects.
- [sink]: An active, externally managed [StringSink]. If provided, the
  caller retains ownership and is responsible for closing it.
- [sinkProvider]: A factory callback that lazily creates a [StringSink] when
  the first item is ready to be written (preventing empty files when [items]
  yields no elements). The created sink is closed automatically upon
  completion or error if it implements [Sink] or [StreamSink].

Example:
```dart
final buffer = StringBuffer();
final stream = Stream.fromIterable([
  {'name': 'Alice', 'age': 30},
  {'name': 'Bob', 'age': 25},
  Future.value({'name': 'Charlie', 'age': 40}),
]);

await jsonlEncodeAsync(
  items: stream,
  sink: buffer,
);
print(buffer.toString());
// Result: '{"name":"Alice","age":30}\n{"name":"Bob","age":25}\n{"name":"Charlie","age":40}\n'
```

---

#### `Future<void> jsonlEncodeBatchAsync<T>(`

- **Source:** `monolib-dart/lib/src/jsonl/jsonl_encode_batch_async.dart`

Asynchronously encodes a stream of [batches] into JSON Lines (JSONL) format
and writes each line to a destination [StringSink].

Delegates batch traversal and lazy sink management to [encodeBatchAsync],
encoding each non-empty batch with [jsonlEncodeAsync]. Exactly one of [sink]
or [sinkProvider] must be provided, or an [ArgumentError] is thrown.

- [batches]: The [Stream] of item batches (`List<T>`) to encode. Each item
  of type [T] is serialized via `jsonEncodeAsync`, which supports nested
  [Future], [Stream], and [Iterable] values, `toJson()` methods, and
  `AsyncJsonWritable` objects.
- [sink]: An active, externally managed [StringSink]. If provided, the
  caller retains ownership and is responsible for closing it.
- [sinkProvider]: A factory callback that lazily creates a [StringSink] when
  the first non-empty batch arrives (preventing empty files when [batches]
  yields no items). The created sink is closed automatically upon completion
  or error if it implements [Sink] or [StreamSink].

Example:
```dart
final batchesStream = Stream.fromIterable([
  [{'name': 'Alice', 'age': 30}],
  [{'name': 'Bob', 'age': 25}],
]);
final buffer = StringBuffer();

await jsonlEncodeBatchAsync(
  batches: batchesStream,
  sink: buffer,
);
print(buffer.toString());
// Result: '{"name":"Alice","age":30}\n{"name":"Bob","age":25}\n'
```

---

#### `class JsonlEncoder extends Converter<List<dynamic>, String>`

- **Source:** `monolib-dart/lib/src/jsonl/jsonl_encoder.dart`

A synchronous [Converter] that encodes a list of JSON-serializable objects
into a JSON Lines (JSONL) [String].

[JsonlEncoder] serves as the synchronous encoder for `JsonlCodec.encoder`.
It serializes each element in a [List] into a single-line JSON string using
[jsonCodec] and appends a trailing newline (`\n`).

Because it buffers the entire output string in memory, use
`jsonlEncodeAsync` instead when streaming large datasets.

Example:
```dart
const encoder = JsonlEncoder(JsonCodec());
final jsonlData = encoder.convert([
  {'id': 'alpha', 'value': 100},
  {'id': 'beta', 'value': 200},
]);
// Result: '{"id":"alpha","value":100}\n{"id":"beta","value":200}\n'
```

##### Public Members

**Constructors:**
- `const JsonlEncoder(Codec<Object?, String> jsonCodec)` — Creates a [JsonlEncoder] configured with [jsonCodec].

**Methods & Operators:**
- `String convert(List<dynamic> items)` — Synchronously encodes [items] into a JSONL [String].

---

#### `class JsonlMappedBatchDecoder<T> extends ChunkedOnlyConverter<String, List<T>>`

- **Source:** `monolib-dart/lib/src/jsonl/jsonl_mapped_batch_decoder.dart`

A streaming converter that parses chunked JSON Lines (JSONL) string data,
maps each decoded JSON object into a domain object of type [T], and emits
mapped items in per-chunk batches (`List<T>`).

[JsonlMappedBatchDecoder] extends [ChunkedOnlyConverter] and combines
[JsonlBaseChunkSink] with [BatchingSinkMixin]. Each parsed line is decoded
with [jsonCodec] and passed to [fromJson]; non-null results are accumulated
and flushed as a single `List<T>` batch at the end of each input chunk,
reducing stream event overhead on high-volume JSONL streams.

For one-by-one emission of mapped items, see [JsonlMappedDecoder].

Example:
```dart
final fileStream = File('large_data.jsonl').openRead().transform(utf8.decoder);

final batchStream = fileStream.transform(
  JsonlMappedBatchDecoder<MyModel>(
    (json) => MyModel.fromJson(json as Map<String, dynamic>),
    ignoreExceptions: true,
  ),
);

await for (final batch in batchStream) {
  await insertModelsToDatabase(batch);
}
```

##### Public Members

**Constructors:**
- `const JsonlMappedBatchDecoder( T? Function(dynamic) fromJson, { bool ignoreExceptions = false, Codec<Object?, String> jsonCodec = const JsonCodec(), void Function(List<T> batch)? onBatch, void Function()? onDone, })` — Creates a [JsonlMappedBatchDecoder] that maps decoded JSON lines using

**Methods & Operators:**
- `Sink<String> startChunkedConversion(Sink<List<T>> sink)` — Starts a chunked conversion that parses incoming JSONL string chunks, maps

---

#### `class JsonlMappedDecoder<T> extends ChunkedOnlyConverter<String, T>`

- **Source:** `monolib-dart/lib/src/jsonl/jsonl_mapped_decoder.dart`

A streaming converter that parses chunked JSON Lines (JSONL) string data and
maps each decoded JSON object into a domain object of type [T].

[JsonlMappedDecoder] extends [ChunkedOnlyConverter] and uses
[JsonlBaseChunkSink] to split incoming string chunks into individual lines.
Each line is decoded with [jsonCodec] and passed to [fromJson]; non-null
results are emitted individually downstream, while `null` results are
skipped.

For batched emission of mapped items per chunk, see [JsonlMappedBatchDecoder].

Example:
```dart
final fileStream = File('data.jsonl').openRead().transform(utf8.decoder);

final modelStream = fileStream.transform(
  JsonlMappedDecoder<MyModel>(
    (json) => MyModel.fromJson(json as Map<String, dynamic>),
    ignoreExceptions: true,
  ),
);

await for (final model in modelStream) {
  print(model.id);
}
```

##### Public Members

**Constructors:**
- `const JsonlMappedDecoder( T? Function(dynamic) fromJson, { bool ignoreExceptions = false, Codec<Object?, String> jsonCodec = const JsonCodec(), void Function()? onDone, })` — Creates a [JsonlMappedDecoder] that maps decoded JSON lines using [fromJson].

**Methods & Operators:**
- `Sink<String> startChunkedConversion(Sink<T> sink)` — Starts a chunked conversion that parses incoming JSONL string chunks, maps

---

<a id="monolib_dart-cli-dart"></a>
### CLI — Command-Line Flag Parser

- **Import:** `import 'package:monolib_dart/cli.dart';`
- **Overview:** Command-line argument and flag parsing utilities.

#### `class Flag`

- **Source:** `monolib-dart/lib/src/cli/flag.dart`

A command-line flag specification with mutating argument-parsing utilities.

Defines a command-line option by its [short] name, [long] name, and
[description], and provides methods to extract the flag and its associated
value from a mutable list of raw CLI arguments.

When a flag is matched, its token (and optional value) is removed in place
from the argument list so that multiple [Flag] definitions can iteratively
consume recognized options until only positional arguments or unknown flags
remain.

Supports standalone short flags (`-v`), combined short flag clusters
(`-xv`), and long flags (`--verbose`), classifying matches via
[FlagFindResult] and [FlagFindType].

Example:
```dart
final args = ['-xv', '--file', 'data.txt'];
final verboseFlag = Flag(
  short: '-v',
  long: '--verbose',
  description: 'Enable verbose output',
);

if (verboseFlag.hasFlag(args)) {
  print('Verbose mode enabled!');
  // args is now: ['-x', '--file', 'data.txt']
}
```

##### Public Members

**Constructors:**
- `Flag({this.short, this.long, required this.description})` — Creates a [Flag] specification.

**Properties & Getters:**
- `final String? short` — The optional single-character short identifier for the flag (e.g., `-v`).
- `final String? long` — The optional long identifier for the flag (e.g., `--verbose`).
- `final String description` — A human-readable description explaining the purpose of the flag.
- `String get shortOrLong` — Returns the [short] identifier if non-null, or the [long] identifier
- `String get longOrShort` — Returns the [long] identifier if non-null, or the [short] identifier

**Methods & Operators:**
- `FlagFindResult? findAndRemoveFlag(List<String> args)` — Searches [args] for this flag, removes the matched flag from [args], and
- `bool hasFlag(List<String> args)` — Returns `true` if this flag is present in [args], removing it in the
- `String? getFlagValue(List<String> args)` — Extracts and removes both this flag and its required value from [args].
- `OptionalFlagResult getOptionalFlagValue(List<String> args)` — Extracts and removes this flag and its optional value from [args].
- `String toString()` — Returns a formatted string combining the flag's identifiers and

---

#### `class FlagFindResult`

- **Source:** `monolib-dart/lib/src/cli/flag_find_result.dart`

The result of locating and removing a [Flag] from an argument list.

Returned by [Flag.findAndRemoveFlag] after stripping the matched flag token
from the argument list. Retains the match [index], syntax [type], and
originating [matchedFlag] so callers like [Flag.getFlagValue] and
[Flag.getOptionalFlagValue] can determine whether a subsequent value token
may be consumed.

Example:
```dart
final flag = Flag(short: '-o', long: '--output', description: 'Output file');
final args = ['-v', '-o', 'report.txt'];

final result = flag.findAndRemoveFlag(args);
if (result != null) {
  print('Flag found at index ${result.index}');
  // args is now: ['-v', 'report.txt']
}
```

##### Public Members

**Constructors:**
- `FlagFindResult(this.index, this.type, this.matchedFlag)` — Creates a [FlagFindResult] with the match [index], syntax [type], and

**Properties & Getters:**
- `final int index` — The index in the mutated argument list where the flag was found.
- `final FlagFindType type` — The syntactic format in which the flag was matched.
- `final Flag matchedFlag` — The [Flag] instance that matched the argument token.

---

#### `enum FlagFindType`

- **Source:** `monolib-dart/lib/src/cli/flag_find_type.dart`

The syntactic format in which a [Flag] was matched in an argument list.

Used by [FlagFindResult] to distinguish between standalone flags (`--verbose`
or `-v`), which can consume the next token as a value, and combined short
flags (`-xv`), which cannot.

Example:
```dart
final flag = Flag(short: '-v', long: '--verbose', description: 'Verbose mode');
final result = flag.findAndRemoveFlag(['-xvc']);

if (result?.type == FlagFindType.shortCombined) {
  print('Found as a combined short flag!');
}
```

##### Public Members

**Values:**
- `long` — Matched by its long identifier as a standalone token (e.g., `--help`).
- `shortStandalone` — Matched by its short identifier as a standalone token (e.g., `-h`).
- `shortCombined` — Matched as part of a combined cluster of short flags (e.g., `-v` inside

---

#### `class FlagNotPresent extends OptionalFlagResult`

- **Source:** `monolib-dart/lib/src/cli/optional_flag_result.dart`

Indicates that the target [Flag] was not present in the argument list.

---

#### `class FlagPresent extends OptionalFlagResult`

- **Source:** `monolib-dart/lib/src/cli/optional_flag_result.dart`

Indicates that the target [Flag] was matched and removed from the argument
list, optionally with an extracted [value].

##### Public Members

**Constructors:**
- `FlagPresent(this.value)` — Creates a [FlagPresent] result with the optional [value].

**Properties & Getters:**
- `final String? value` — The argument value that immediately followed the matched flag, or `null`

---

<a id="monolib_dart-io-dart"></a>
### I/O — File System, I/O Sinks & Batch JSONL Writers

- **Import:** `import 'package:monolib_dart/io.dart';`
- **Overview:** File system, I/O sink, and batch JSON Lines writer utilities.

#### `extension FileEnsureOpenExtension on File`

- **Source:** `monolib-dart/lib/src/io/file_ensure_open_extension.dart`

Extension on [File] that ensures parent directories exist before opening a
writable [IOSink].

##### Public Members

**Methods & Operators:**
- `Future<IOSink> openWriteEnsureParent({ bool recursive = false, FileMode mode = FileMode.write, Encoding encoding = utf8, }) async` — Opens a writable [IOSink] on this file after creating its [parent]

---

#### `class JsonlBatchWriter<T>`

- **Source:** `monolib-dart/lib/src/io/jsonl_batch_writer.dart`

A buffered writer that combines a [Batcher] and an [IOSink] to write items
to a JSON Lines (JSONL) file in batches.

[JsonlBatchWriter] accepts items synchronously via [add], buffers them in
memory using a [Batcher], and periodically flushes them as JSONL lines to
the target [File] using [jsonlEncodeAsync]. The underlying [IOSink] is
opened lazily on the first flush.

Example:
```dart
final writer = JsonlBatchWriter<Map<String, Object>>(
  file: File('logs.jsonl'),
  maxBatchSize: 50,
  maxDuration: const Duration(seconds: 1),
);

writer.add({'event': 'app_start', 'timestamp': DateTime.now().toIso8601String()});
writer.add({'event': 'login', 'userId': 123});

await writer.dispose();
```

##### Public Members

**Constructors:**
- `JsonlBatchWriter({ required File file, int? maxBatchSize = 100, Duration? maxDuration = const Duration(milliseconds: 100), void Function(Object error, StackTrace stackTrace)? onError, })` — Creates a [JsonlBatchWriter] that lazily appends to the provided [File].

**Methods & Operators:**
- `void add(T item)` — Adds an [item] to the internal buffer to be later written to the file.
- `Future<void> dispose({Function? onSinkCloseError}) async` — Flushes any pending items to disk and safely closes the file handle.

---

#### `extension OnFileSystemEntity on FileSystemEntity`

- **Source:** `monolib-dart/lib/src/io/on_file_system_entity.dart`

Extension on [FileSystemEntity] that provides non-throwing deletion.

##### Public Members

**Methods & Operators:**
- `Future<void> deleteQuietly({bool recursive = false}) async` — Asynchronously deletes this [FileSystemEntity], ignoring any exceptions.

---

#### `extension OnFunction on IOSink Function()`

- **Source:** `monolib-dart/lib/src/io/on_function.dart`

Extension on `IOSink Function()` that provides scoped lifecycle management
for dynamically created [IOSink] instances.

##### Public Members

**Methods & Operators:**
- `Future<void> withIOSink(Future<void> Function(IOSink) call) async` — Invokes this factory to acquire an [IOSink], executes [call] with it, and

---

#### `extension OnIoSink on IOSink`

- **Source:** `monolib-dart/lib/src/io/on_io_sink.dart`

Extension on [IOSink] that provides scoped lifecycle management.

##### Public Members

**Methods & Operators:**
- `Future<T> withIOSink<T>(Future<T> Function(IOSink) call) async` — Executes [call] with this [IOSink] and guarantees that [close] is awaited

---

<a id="monolib_dart-zalgo-dart"></a>
### Zalgo — Zalgo Text Encoding & Decoding

- **Import:** `import 'package:monolib_dart/zalgo.dart';`
- **Overview:** Zalgo text generation and encoding utilities.

#### `bool isZalgoEncodableCodeUnit(int codeUnit)`

- **Source:** `monolib-dart/lib/src/zalgo/zalgo.dart`

Checks whether [codeUnit] can be encoded as a Zalgo combining modifier.

Valid encodable code units are standard printable ASCII characters in the
inclusive range `[32, 126]` (from space to tilde).

See also:
* [isZalgoDecodableCodeUnit], which checks the reverse mapping.
* [zalgoEncode], which encodes a string using this range.

---

#### `bool isZalgoDecodableCodeUnit(int codeUnit)`

- **Source:** `monolib-dart/lib/src/zalgo/zalgo.dart`

Checks whether [codeUnit] is a Zalgo combining modifier that can be decoded
back into a printable ASCII character.

Valid decodable code units fall within the Unicode combining diacritical
marks block starting at `U+0300` (`[0x300, 0x35E]`).

See also:
* [isZalgoEncodableCodeUnit], which checks the forward mapping.
* [zalgoDecodeSingle], which decodes a Zalgo grapheme cluster.

---

#### `String zalgoDecodeSingle(String input)`

- **Source:** `monolib-dart/lib/src/zalgo/zalgo.dart`

Decodes a single Zalgo-encoded grapheme cluster back into its original
ASCII string.

The [input] must start with a printable ASCII base character followed by
zero or more Zalgo combining modifiers. Each combining modifier is shifted
back to its original ASCII code unit.

Throws an [Exception] if [input] is empty, if the base character is not
printable ASCII, or if any subsequent code unit is not a valid Zalgo
combining modifier.

Example:
```dart
final encoded = zalgoEncode('Hi');
final decoded = zalgoDecodeSingle(encoded);
print(decoded); // 'Hi'
```

---

#### `String zalgoEncode(String input)`

- **Source:** `monolib-dart/lib/src/zalgo/zalgo.dart`

Encodes an ASCII [input] string into a single Zalgo grapheme cluster.

Keeps the first character of [input] as the base character and converts all
subsequent characters into Unicode combining diacritical marks starting at
`U+0300`.

Throws an [Exception] if [input] is empty or if any character in [input]
is outside the printable ASCII range.

Example:
```dart
final obfuscated = zalgoEncode('Secret');
print(obfuscated); // Outputs visually glitched text
```

---

<a id="monolib_dart-monolib_dart-dart"></a>
### Core Utilities — Extensions, Data Structures & Tables

- **Import:** `import 'package:monolib_dart/monolib_dart.dart';`
- **Overview:** General-purpose extensions, data structures, and utilities for Dart projects.

#### `class Batcher<T>`

- **Source:** `monolib-dart/lib/src/general/batcher.dart`

A buffer that aggregates synchronous items and flushes them in periodic or
size-bounded batches.

Collects items added via [add] into a [List] and passes each batch to
[onBatch] whenever:
1. The number of buffered items reaches [maxBatchSize], or
2. [maxDuration] has elapsed since the first item in the current batch was
   added (the timer is started lazily only while the buffer is non-empty), or
3. [dispose] is called.

Batch callbacks are serialized so that each [onBatch] invocation waits for
the previous batch's [Future] to complete before running.

Example:
```dart
final analyticsBatcher = Batcher<Map<String, dynamic>>(
  maxBatchSize: 50,
  maxDuration: const Duration(seconds: 5),
  onBatch: (List<Map<String, dynamic>> events) async {
    await api.sendEvents(events);
  },
);

analyticsBatcher.add({'event': 'click', 'target': 'login_btn'});
analyticsBatcher.add({'event': 'scroll', 'depth': 80});

await analyticsBatcher.dispose();
```

##### Public Members

**Constructors:**
- `Batcher({ int? maxBatchSize, Duration? maxDuration, required FutureOr<void> Function(List<T>) onBatch, bool throwOnAddAfterDispose = true, })` — Creates a [Batcher] that flushes buffered items to [onBatch].

**Methods & Operators:**
- `void add(T item)` — Adds [item] to the current batch buffer.
- `Future<void> dispose() async` — Disposes this batcher, flushing any remaining buffered items and awaiting

---

#### `class DenseTable<T>`

- **Source:** `monolib-dart/lib/src/general/dense_table.dart`

A dense two-dimensional table of elements of type [T] backed by a single
flat [List].

Stores elements in row-major order at index `(row * columns) + col`,
avoiding the nested allocations and pointer indirection of a
`List<List<T>>`.

Example:
```dart
final table = DenseTable<int>.filled(3, 3, 0);
table.set(1, 1, 99);
print(table.get(1, 1)); // 99
```

##### Public Members

**Constructors:**
- `DenseTable.filled(int rows, int columns, T fillValue)` — Creates a table with the given number of [rows] and [columns],
- `DenseTable.generate( int rows, int columns, T Function(int row, int col) generator, )` — Creates a table with the given number of [rows] and [columns], populating

**Properties & Getters:**
- `int get rows` — The number of rows in the table.
- `int get columns` — The number of columns in the table.

**Methods & Operators:**
- `T get(int row, int col)` — Returns the element at [row] and [col].
- `void set(int row, int col, T value)` — Sets the element at [row] and [col] to [value].

---

#### `class Float64Table`

- **Source:** `monolib-dart/lib/src/general/float64_table.dart`

A dense two-dimensional table of 64-bit floating-point numbers backed by a
single flat [Float64List].

Stores elements in row-major order at index `(row * columns) + col`,
avoiding the nested allocations and pointer indirection of a
`List<List<double>>`.

Example:
```dart
final table = Float64Table.filled(3, 3, 0.0);
table.set(1, 1, 99.5);
print(table.get(1, 1)); // 99.5
```

##### Public Members

**Constructors:**
- `Float64Table.filled(int rows, int columns, double fillValue)` — Creates a table with the given number of [rows] and [columns],
- `Float64Table.generate( int rows, int columns, double Function(int row, int col) generator, )` — Creates a table with the given number of [rows] and [columns], populating

**Properties & Getters:**
- `int get rows` — The number of rows in the table.
- `int get columns` — The number of columns in the table.

**Methods & Operators:**
- `double get(int row, int col)` — Returns the element at [row] and [col].
- `void set(int row, int col, double value)` — Sets the element at [row] and [col] to [value].

---

#### `class Int32Table`

- **Source:** `monolib-dart/lib/src/general/int32_table.dart`

A dense two-dimensional table of 32-bit integers backed by a single flat
[Int32List].

Stores elements in row-major order at index `(row * columns) + col`,
avoiding the nested allocations and pointer indirection of a
`List<List<int>>`.

Example:
```dart
final table = Int32Table.filled(3, 3, 0);
table.set(1, 1, 42);
print(table.get(1, 1)); // 42
```

##### Public Members

**Constructors:**
- `Int32Table.filled(int rows, int columns, int fillValue)` — Creates a table with the given number of [rows] and [columns],
- `Int32Table.generate( int rows, int columns, int Function(int row, int col) generator, )` — Creates a table with the given number of [rows] and [columns], populating

**Properties & Getters:**
- `int get rows` — The number of rows in the table.
- `int get columns` — The number of columns in the table.

**Methods & Operators:**
- `int get(int row, int col)` — Returns the element at [row] and [col].
- `void set(int row, int col, int value)` — Sets the element at [row] and [col] to [value].

---

#### `extension OnBool on bool`

- **Source:** `monolib-dart/lib/src/general/on_bool.dart`

Extension on [bool] that supports multi-field comparator chains.

Since [bool] does not implement [Comparable] in Dart, this extension
provides a way to chain boolean comparisons with fallback comparators.

##### Public Members

**Methods & Operators:**
- `int? compareChain(bool other)` — Compares this boolean with [other], returning `null` when they are equal.

---

#### `int? compareChain(T other)`

- **Source:** `monolib-dart/lib/src/general/on_comparable.dart`

Compares this value with [other], returning `null` when they are equal.

Delegates to [Comparable.compareTo] and returns `null` instead of `0` when
both values are equal, allowing fallback comparisons to be chained with
the `??` operator.

Example:
```dart
people.sort((a, b) {
  return a.lastName.compareChain(b.lastName) ??
      a.firstName.compareChain(b.firstName) ??
      a.age.compareTo(b.age);
});
```

---

#### `extension Iso8601WithTimeZone on DateTime`

- **Source:** `monolib-dart/lib/src/general/on_date_time.dart`

Extension on [DateTime] that provides timezone-aware ISO 8601 formatting.

##### Public Members

**Methods & Operators:**
- `String toIso8601StringWithTz()` — Returns an ISO 8601 string representation of this [DateTime] with an

---

#### `extension OnDouble on double`

- **Source:** `monolib-dart/lib/src/general/on_double.dart`

Extension on [double] that formats values as five-moon rating strings.

##### Public Members

**Methods & Operators:**
- `String toFiveMoonRating()` — Converts this [double] in the range `0.0` to `1.0` into a five-moon rating

---

#### `extension OnFunctionWithNoArguments<T> on T Function()`

- **Source:** `monolib-dart/lib/src/general/on_function_with_no_arguments.dart`

Extension on zero-argument functions returning [T] that provides retry
logic.

##### Public Members

**Methods & Operators:**
- `T callWithRetryOnFailure({int times = 3})` — Invokes this function and retries up to [times] total attempts if it

---

#### `return call.callWithRetryOnFailure(times: times)`

- **Source:** `monolib-dart/lib/src/general/on_function_with_no_arguments.dart`

---

#### `extension OnFutureFunction<T> on Future<T> Function()`

- **Source:** `monolib-dart/lib/src/general/on_future_function.dart`

Extension on zero-argument functions returning a [Future] of [T] that
provides retry logic.

##### Public Members

**Methods & Operators:**
- `Future<T> asyncCallWithRetryOnFailure({int times = 3}) async` — Invokes this function and retries up to [times] total attempts if the

---

#### `return call.asyncCallWithRetryOnFailure(times: times)`

- **Source:** `monolib-dart/lib/src/general/on_future_function.dart`

---

#### `extension OnInt on int`

- **Source:** `monolib-dart/lib/src/general/on_int.dart`

Extension on [int] that provides nullable index conversion and extended
radix formatting.

##### Public Members

**Properties & Getters:**
- `int? get asNullableIndex` — Returns `null` if this integer is `-1`, or this integer otherwise.

**Methods & Operators:**
- `String toExtendedRadixString(int radix)` — Converts this integer to a string representation in the given [radix].

---

#### `extension OnIterable<T> on Iterable<T>`

- **Source:** `monolib-dart/lib/src/general/on_iterable.dart`

Extension on [Iterable] that provides emptiness callbacks and summation
utilities.

##### Public Members

**Methods & Operators:**
- `Iterable<T> onEmpty(void Function() onEmpty)` — Returns a lazy [OnEmptyIterable] that invokes [onEmpty] when iterating
- `T sum({T? zero})` — Sums all elements in this iterable using dynamic dispatch of the `+`
- `R sumBy<R>(R Function(T) mapper, {R? zero})` — Maps each element using [mapper] and sums the resulting values in a single

---

#### `extension OnIterableOfIterables<T> on Iterable<Iterable<T>>`

- **Source:** `monolib-dart/lib/src/general/on_iterable_of_iterables.dart`

Extension on [Iterable] of [Iterable]s that provides interleaving and
element-wise averaging.

##### Public Members

**Properties & Getters:**
- `Iterable<T> get mixed sync*` — Lazily interleaves elements from all child iterables in round-robin order.

**Methods & Operators:**
- `Iterable<T> average() sync*` — Lazily computes the element-wise truncating average across all child

---

#### `extension OnIterableOfNullableBoolFunctions<T> on Iterable<bool Function(T)?>`

- **Source:** `monolib-dart/lib/src/general/on_iterable_of_nullable_bool_functions.dart`

Extension on [Iterable] of nullable predicates that combines them into a
single predicate.

Filters out `null` elements via [NullableIterableExtensions.nonNulls] before
combining the remaining predicates.

##### Public Members

**Properties & Getters:**
- `bool Function(T)? get combinedEvery` — Combines all non-null predicates in this iterable using logical AND
- `bool Function(T)? get combinedAny` — Combines all non-null predicates in this iterable using logical OR (`||`).

---

#### `extension OnIterableOfNullableFunctions<T> on Iterable<T Function(T)?>`

- **Source:** `monolib-dart/lib/src/general/on_iterable_of_nullable_functions.dart`

Extension on [Iterable] of nullable transformation functions that composes
them into a single function.

Filters out `null` elements via [NullableIterableExtensions.nonNulls] before
composing the remaining functions.

##### Public Members

**Properties & Getters:**
- `T Function(T)? get combined` — Composes all non-null functions in this iterable into a single function

---

#### `extension OnIterableOfNum on Iterable<num>`

- **Source:** `monolib-dart/lib/src/general/on_iterable_of_num.dart`

Extension on [Iterable] of [num] that provides element-wise division.

##### Public Members

**Methods & Operators:**
- `Iterable<double> operator /(num divisor)` — Lazily divides each element in this iterable by [divisor].

---

#### `extension OnList<T> on List<T>`

- **Source:** `monolib-dart/lib/src/general/on_list.dart`

Extension on [List] that provides draining, eager mapping, binary-search
insertion, and formatting utilities.

##### Public Members

**Methods & Operators:**
- `Iterable<T> drain() sync*` — Lazily removes and yields elements from the end of this list until it is
- `Iterable<R> drainMap<R>(R Function(T) mapper) sync*` — Lazily removes elements from the end of this list and yields the result of
- `List<E> toMappedList<E>(E Function(T) mapper, {bool growable = true})` — Eagerly maps each element of this list using [mapper] and returns a new
- `List<E> toIndexedMappedList<E>( E Function(T, int index) mapper, { bool growable = true, })` — Eagerly maps each element and its index using [mapper] and returns a new
- `int insertSorted(T element, {int Function(T a, T b)? compare})` — Inserts [element] into this sorted list while preserving its sorted order,
- `int? closestIndexOfTo(T element, int index)` — Searches outward in both directions from [index] and returns the index of
- `bool deepEquals(List<T> other)` — Returns `true` if this list and [other] have the same length and equal
- `String joinWith({ String prefix = '', String delimiter = '', String suffix = '', String Function(T)? map, String Function()? ifEmpty, })` — Joins the elements of this list into a string separated by [delimiter] and

---

#### `extension OnListOfLists on List<List>`

- **Source:** `monolib-dart/lib/src/general/on_list_of_lists.dart`

Extension on [List] of [List]s that formats two-dimensional data as a
plain-text table.

##### Public Members

**Methods & Operators:**
- `void formatTable(StringSink sink)` — Writes this two-dimensional list as a space-padded plain-text table to

---

#### `extension OnNullableComparable<T> on Comparable<T>?`

- **Source:** `monolib-dart/lib/src/general/on_nullable_comparable.dart`

Extension on nullable [Comparable] values that provides null-safe
comparison.

Treats `null` as less than any non-null value so nullable fields can be
compared directly in `sort` callbacks without manual null checks.

Example:
```dart
final list = <int?>[3, null, 1, 2];
list.sort((a, b) => a.compare(b));
// [null, 1, 2, 3]
```

##### Public Members

**Methods & Operators:**
- `int compare(T? other)` — Compares this nullable value with [other], treating `null` as less than

---

#### `extension OnNullableObject<T> on T?`

- **Source:** `monolib-dart/lib/src/general/on_nullable_object.dart`

Extension on nullable objects that provides chainable non-null assertions.

Enables inline null validation within expression pipelines (such as looking
up a required entry in `Pillar`) without breaking the call chain for an
imperative `if` check.

##### Public Members

**Methods & Operators:**
- `T assertNotNull(Exception Function() exceptionProducer)` — Returns this value as a non-nullable [T], or throws the [Exception]

---

#### `extension OnNullableIterable<T> on Iterable<T>?`

- **Source:** `monolib-dart/lib/src/general/on_nullable_iterable.dart`

Extension on nullable [Iterable]s.

##### Public Members

**Properties & Getters:**
- `bool get isNullOrEmpty` — Returns `true` if this iterable is `null` or empty.
- `bool get isNotNullNorEmpty` — Returns `true` if this iterable is not `null` and not empty.

---

#### `extension OnNullableMap<K, V> on Map<K, V>?`

- **Source:** `monolib-dart/lib/src/general/on_nullable_map.dart`

Extension on nullable [Map]s.

##### Public Members

**Properties & Getters:**
- `bool get isNullOrEmpty` — Returns `true` if this map is `null` or empty.
- `bool get isNotNullNorEmpty` — Returns `true` if this map is not `null` and not empty.

---

#### `extension OnNullableString on String?`

- **Source:** `monolib-dart/lib/src/general/on_nullable_string.dart`

Extension on nullable [String]s that normalizes empty strings to `null` and provides empty checks.

##### Public Members

**Properties & Getters:**
- `bool get isNullOrEmpty` — Returns `true` if this string is `null` or empty.
- `bool get isNotNullNorEmpty` — Returns `true` if this string is not `null` and not empty.

**Methods & Operators:**
- `String? emptyToNull()` — Returns `null` if this string is `null` or empty (`''`), or this string

---

#### `extension OnObject<T> on T`

- **Source:** `monolib-dart/lib/src/general/on_object.dart`

Extension on any object [T] that provides Kotlin-style scoping and casting
methods.

Enables fluent method chaining, inline transformations, and side-effect
execution without introducing intermediate local variables.

##### Public Members

**Methods & Operators:**
- `T also(void Function(T x) call)` — Invokes [call] with `this` as its argument and returns `this`.
- `R let<R>(R Function(T x) call)` — Transforms `this` into a value of type [R] by passing it to [call].
- `T maybeLet(T Function(T x)? call)` — Transforms `this` using [call] if [call] is non-null, or returns `this`
- `R castTo<R>()` — Casts `this` to [R].

---

#### `class Once`

- **Source:** `monolib-dart/lib/src/general/once.dart`

A guard that ensures a callback is executed at most once.

Useful for idempotent lifecycle operations such as resource disposal or
one-time initialization.

Example:
```dart
final cleanup = Once();
cleanup.attempt(() => print('Cleaning up...')); // Prints
cleanup.attempt(() => print('Cleaning up...')); // Ignored
```

##### Public Members

**Properties & Getters:**
- `bool get executed` — Whether an action has already been executed by this [Once] instance.

**Methods & Operators:**
- `void attempt(void Function() call)` — Executes [call] if this [Once] instance has not yet been triggered.
- `void Function() wrap(void Function() call)` — Returns a zero-argument function that invokes [call] at most once via

---

#### `class TableCellAlignLeft`

- **Source:** `monolib-dart/lib/src/general/table_cell_align_left.dart`

A cell wrapper that forces left alignment when formatted by `formatTable`.

By default, `formatTable` right-aligns [num] values and left-aligns all
other values. Wrapping a value (such as a [num]) in [TableCellAlignLeft]
overrides this behavior so the cell is padded on the right.

Example:
```dart
final table = [
  ['ID', 'Value'],
  [1, 100],
  [2, TableCellAlignLeft(200)],
];
final buffer = StringBuffer();
table.formatTable(buffer);
```

##### Public Members

**Constructors:**
- `const TableCellAlignLeft(this.value)` — Creates a [TableCellAlignLeft] wrapper around [value].

**Properties & Getters:**
- `final dynamic value` — The underlying cell value to format as a left-aligned string.

**Methods & Operators:**
- `String toString()` — Returns the string representation of [value].

---

#### `class TableCellAlignRight`

- **Source:** `monolib-dart/lib/src/general/table_cell_align_right.dart`

A cell wrapper that forces right alignment when formatted by `formatTable`.

By default, `formatTable` right-aligns [num] values and left-aligns all
other values. Wrapping a non-numeric value in [TableCellAlignRight]
overrides this behavior so the cell is padded on the left.

Example:
```dart
final table = [
  ['Name', 'Score'],
  ['Alice', TableCellAlignRight('95.5%')],
  ['Bob', TableCellAlignRight('80.0%')],
];
final buffer = StringBuffer();
table.formatTable(buffer);
```

##### Public Members

**Constructors:**
- `const TableCellAlignRight(this.value)` — Creates a [TableCellAlignRight] wrapper around [value].

**Properties & Getters:**
- `final dynamic value` — The underlying cell value to format as a right-aligned string.

**Methods & Operators:**
- `String toString()` — Returns the string representation of [value].

---

## `monolib_flutter`

Flutter widgets, extensions, Pillar ChangeNotifier adapters, and Zalgo text utilities.

<a id="monolib_flutter-monolib_flutter-dart"></a>
### Flutter Utilities — Widgets, Context/Scroll Extensions & Pillar Listenable

- **Import:** `import 'package:monolib_flutter/monolib_flutter.dart';`
- **Overview:** General-purpose extensions, widgets, and Pillar adapters for Flutter projects.

#### `extension OnBuildContext on BuildContext`

- **Source:** `monolib-flutter/lib/src/general/on_build_context.dart`

Extension on [BuildContext] that provides convenient access to the nearest
[ThemeData] in the widget tree.

Example:
```dart
Widget build(BuildContext context) {
  return Text(
    'Styled Text',
    style: context.theme.textTheme.bodyLarge,
  );
}
```

##### Public Members

**Properties & Getters:**
- `ThemeData get theme` — Resolves the nearest [ThemeData] from the widget tree hierarchy.

---

#### `extension OnScrollController on ScrollController`

- **Source:** `monolib-flutter/lib/src/general/on_scroll_controller.dart`

Extension on [ScrollController] that provides programmatic scrolling
utilities, such as auto-scrolling to the bottom of dynamic lists, chat
interfaces, or log viewers.

##### Public Members

**Methods & Operators:**
- `Future<void> scrollToTheEnd()` — Repeatedly animates the scroll position to the bottom until the end is reached.

---

#### `extension OnTextEditingValue on TextEditingValue`

- **Source:** `monolib-flutter/lib/src/general/on_text_editing_value.dart`

Extension on [TextEditingValue] that resolves the active text range based on
the current cursor selection.

Primarily used to isolate the active typing context from trailing text for
pattern matching or autocomplete in text input workflows.

##### Public Members

**Properties & Getters:**
- `TextRange get textMatchingContext` — Resolves the contextual [TextRange] of [text] that should be evaluated

---

#### `class StreamBuilderForList<T> extends StatelessWidget`

- **Source:** `monolib-flutter/lib/src/general/stream_builder_for_list.dart`

A [StatelessWidget] that wraps [StreamBuilder] with dedicated builder
callbacks for loading, error, empty, and populated [List] states.

While [StreamBuilder] exposes a raw [AsyncSnapshot] that requires manual
evaluation of data availability and error states, [StreamBuilderForList]
delegates rendering to distinct callbacks based on the snapshot's state.

By distinguishing between a `null` data state (loading) and an empty `[]`
list state, it simplifies list-based UI patterns (such as rendering a
[ListView] with an empty-state placeholder).

Example:
```dart
StreamBuilderForList<String>(
  stream: myStringListStream,
  onLoading: (context) => const CircularProgressIndicator(),
  onEmpty: (context) => const Text('No results available.'),
  onError: (context, error) => Text('Failed to load: $error'),
  onData: (context, data) {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) => Text(data[index]),
    );
  },
)
```

##### Public Members

**Constructors:**
- `const StreamBuilderForList({ required this.stream, required this.onData, this.onEmpty, this.onLoading, this.onError, super.key, })` — Creates a [StreamBuilderForList] to handle a [Stream] of [List]s.

**Properties & Getters:**
- `final Stream<List<T>> stream` — The asynchronous [Stream] of [List]s to which this builder is subscribed.

**Methods & Operators:**
- `final Widget Function(BuildContext context, List<T> data) onData` — The builder callback invoked when the stream emits a non-empty [List].
- `final Widget Function(BuildContext context)? onEmpty` — The builder callback invoked when the stream emits an empty [List].
- `final Widget Function(BuildContext context)? onLoading` — The builder callback invoked when the stream is actively waiting for its
- `final Widget Function(BuildContext context, Object error)? onError` — The builder callback invoked when the stream emits an error.
- `Widget build(BuildContext context)`

---

#### `extension OnPillarListenable on PillarListenable`

- **Source:** `monolib-flutter/lib/src/pillar/on_pillar_listenable.dart`

Extension on [PillarListenable] that adapts it into a Flutter [Listenable].

Allows pure Dart [PillarListenable] instances (such as those returned by
[Pillar.changeNotifierFor]) to be consumed directly by Flutter widgets like
`ListenableBuilder` or `AnimatedBuilder`.

##### Public Members

**Properties & Getters:**
- `Listenable get asListenable` — Returns this [PillarListenable] as a Flutter [Listenable].

---

<a id="monolib_flutter-zalgo-dart"></a>
### Flutter Zalgo — Text Range Mapping for Flutter Text Editing

- **Import:** `import 'package:monolib_flutter/zalgo.dart';`
- **Overview:** Zalgo text range mapping utilities for Flutter text editing.

#### `List<ZalgoTextRange> mapZalgoRanges(String input)`

- **Source:** `monolib-flutter/lib/src/zalgo/map_zalgo_ranges.dart`

Parses [input] into non-overlapping [ZalgoTextRange] segments of plain text
and Zalgo grapheme clusters.

Scans [input]'s code units in a single pass, using
[isZalgoEncodableCodeUnit] to detect potential base characters and
[isZalgoDecodableCodeUnit] to identify subsequent combining modifiers.

If [input] is empty, returns a single collapsed, non-Zalgo range: `[0, 0)`.

Because Zalgo text is encoded at the grapheme cluster level (one base
character followed by combining modifiers), contiguous Zalgo clusters are
returned as separate [ZalgoTextRange] entries rather than merged into a
single range.

Example:
```dart
final ranges = mapZalgoRanges('Hi e̵̟̎x̴̝̾');

// ranges[0] is plain text 'Hi '
// ranges[1] is Zalgo text 'e̵̟̎'
// ranges[2] is Zalgo text 'x̴̝̾'
```

---

#### `class ZalgoTextRange extends TextRange`

- **Source:** `monolib-flutter/lib/src/zalgo/zalgo_text_range.dart`

A [TextRange] representing either a plain text segment or a single
Zalgo-encoded grapheme cluster.

Produced by `mapZalgoRanges`, this class pairs standard UTF-16 [start] and
[end] offsets with an [isZalgo] flag. Because a Zalgo grapheme cluster
combines a base character with one or more Unicode combining modifiers, a
Zalgo range spans multiple UTF-16 code units.

##### Public Members

**Constructors:**
- `const ZalgoTextRange({ required super.start, required super.end, required this.isZalgo, })` — Creates a [ZalgoTextRange] with the given [start] and [end] offsets and
- `const ZalgoTextRange.collapsed(super.offset)` — Creates a collapsed [ZalgoTextRange] at [offset] with [isZalgo] set to

**Properties & Getters:**
- `final bool isZalgo` — Whether the bounded segment is a Zalgo-encoded grapheme cluster.
- `int get hashCode` — Generates a hash code combining the `start`, `end`, and [isZalgo] flag.

**Methods & Operators:**
- `String decodedTextInside(String text)` — Extracts the substring bounded by this range from [text], decoding it if
- `bool operator ==(Object other)` — Compares this [ZalgoTextRange] against [other] for equality.
- `String toString()` — Returns a string representation of this range, prefixing the standard

---

## `monolib_openrouter`

Streaming, JSON, and timeout utilities for OpenRouter AI clients in Dart.

<a id="monolib_openrouter-monolib_openrouter-dart"></a>
### OpenRouter Utilities — Streaming Converters, Sinks & Timeouts

- **Import:** `import 'package:monolib_openrouter/monolib_openrouter.dart';`
- **Overview:** Streaming, JSON, and timeout utilities for OpenRouter clients in Dart projects.

#### `class DropLeadingWhitespaceConverter extends Converter<List<int>, List<int>>`

- **Source:** `monolib-openrouter/lib/src/drop_leading_whitespace_converter.dart`

A [Converter] that strips leading ASCII whitespace bytes (`0x20`, `0x0A`,
`0x0D`, `0x09`) from a byte stream before forwarding data downstream.

Prevents JSON parse errors when consuming streaming responses from LLM APIs
(such as OpenRouter) that emit keep-alive pings (e.g., `\r\n`) or padding
bytes before the JSON body begins.

Typically placed ahead of [Utf8Codec.decoder] (`utf8.decoder`) and
[JsonDecoder] in an HTTP response stream pipeline.

Example:
```dart
final pipeline = responseStream.transform(
  const DropLeadingWhitespaceConverter()
      .fuse(utf8.decoder)
      .fuse(json.decoder),
);
```

##### Public Members

**Constructors:**
- `const DropLeadingWhitespaceConverter({ void Function(Object error, StackTrace stackTrace)? onError, })` — Creates a [DropLeadingWhitespaceConverter] that optionally reports

**Methods & Operators:**
- `List<int> convert(List<int> input)` — Returns a slice of [input] starting from the first non-whitespace byte,
- `Sink<List<int>> startChunkedConversion(Sink<List<int>> sink)` — Starts a chunked conversion that strips leading whitespace bytes before

---

#### `extension OnFluentJson on FluentJson`

- **Source:** `monolib-openrouter/lib/src/on_fluent_json.dart`

Extension on [FluentJson] that validates OpenRouter API responses for
top-level error payloads.

OpenRouter HTTP APIs may return a `200 OK` status code with a top-level
`"error"` object when a request fails (for example, due to provider routing
errors or rate limits). This extension checks for such errors before
extracting fields in a fluent chain.

##### Public Members

**Methods & Operators:**
- `FluentJson assertNoTopLevelError()` — Asserts that the JSON payload does not contain a top-level `"error"` node.

---

#### `extension OnFuture<T> on Future<T>`

- **Source:** `monolib-openrouter/lib/src/on_future.dart`

Extension on [Future] that converts time-bounded futures into streams that
close gracefully on timeout.

##### Public Members

**Methods & Operators:**
- `Stream<T> timeoutAsStream({ required Duration timeLimit, void Function()? onTimeout, }) async*` — Converts this [Future] into a single-element [Stream] that closes without

---

#### `extension OnStream<T> on Stream<T>`

- **Source:** `monolib-openrouter/lib/src/on_stream.dart`

Extension on [Stream] that provides graceful timeout termination without
emitting a [TimeoutException].

##### Public Members

**Methods & Operators:**
- `Stream<T> timeoutAndClose({ required Duration timeLimit, void Function()? onTimeout, })` — Returns a [Stream] that closes instead of emitting a [TimeoutException]

---

#### `class Utf8StreamStringSink implements StringSink`

- **Source:** `monolib-openrouter/lib/src/utf8_stream_string_sink.dart`

A [StringSink] that UTF-8 encodes written strings and forwards the resulting
byte chunks to an underlying [EventSink].

Bridges string-producing APIs (such as `jsonEncodeAsync`) directly to
byte-based sinks without buffering the entire string in memory.

Example:
```dart
final controller = StreamController<List<int>>();
final stringSink = Utf8StreamStringSink(controller.sink);

// Encodes iteratively to bytes and adds them directly to the StreamController.
await jsonEncodeAsync(object: {'large': 'payload...'}, sink: stringSink);
```

##### Public Members

**Constructors:**
- `const Utf8StreamStringSink( this._sink, { void Function(Object error, StackTrace stackTrace)? onError, })` — Creates a [Utf8StreamStringSink] that forwards UTF-8 encoded bytes to the

**Methods & Operators:**
- `void write(Object? object)` — Converts [object] to a string, UTF-8 encodes it, and emits the resulting
- `void writeAll(Iterable<dynamic> objects, [String separator = ''])` — Iterates over [objects], writing each one to the underlying sink sequentially,
- `void writeCharCode(int charCode)` — Converts a single Unicode [charCode] into a single-character string, UTF-8
- `void writeln([Object? object = ''])` — Writes the string representation of [object] followed by a newline `\n`

---

