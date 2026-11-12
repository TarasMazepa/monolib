# ToLooks

- [x] **1. Generic JSON Selector Converter for Streaming Pipelines (`JsonMappedConverter`)**
  - **Idea**: Introduce a generic `Converter<dynamic, T>` (e.g. `JsonMappedConverter<T>` / `FluentJsonMappedConverter<T>`) in `monolib-dart` (`package:monolib_dart/fluent_json.dart`) that extracts a target domain object or field using `FluentJson` and implements chunked conversion so it can be fused directly into streaming pipelines with `.fuse()`.
  - **Context**: In streaming pipelines (e.g. Hivebud's OpenRouter-to-JSONL converter), input byte streams are decoded from JSON and need specific fields extracted (such as `choices[0].message.content`) before being forwarded into downstream chunked decoders (such as `CsvMappedBatchDecoder`). Currently, extracting fields requires breaking the stream into multiple `.transform()` / `.map()` calls or implementing ad-hoc converters (like `OpenRouterContentConverter`). A generic selector converter enables fusing `json.decoder` (or `openRouterJsonDecoder`) directly into downstream chunked decoders.
  - **Investigation**:
    1. *API Design*:
       ```dart
       class JsonMappedConverter<T> extends Converter<dynamic, T> {
         final T Function(FluentJson json) _selector;

         const JsonMappedConverter(this._selector);

         @override
         T convert(dynamic input) => _selector(FluentJson.root(input));

         @override
         Sink<dynamic> startChunkedConversion(Sink<T> sink) =>
             _JsonMappedSink<T>(sink, _selector);
       }
       ```
    2. *Pipeline Fusing*:
       Enables clean single-expression pipeline definitions:
       ```dart
       final pipeline = openRouterJsonDecoder
           .fuse(JsonMappedConverter((json) => json.assertNoTopLevelError()['choices'].unboxIterable().first['message'].unboxed<String>('content')))
           .fuse(CsvMappedBatchDecoder(IdNameAndDescription.fromCsv));
       ```
    3. *Placement & Export*:
       Add to `monolib-dart/lib/src/json/json_mapped_converter.dart` and export via `package:monolib_dart/fluent_json.dart`.
  - **Resolution**: Implemented `JsonMappedConverter<T>` in `monolib-dart/lib/src/json/json_mapped_converter.dart` and exported it from `package:monolib_dart/fluent_json.dart`. Added chunked conversion support with optional `onDone` callback, enabling seamless `.fuse()` pipelines between JSON decoders (`json.decoder`, `openRouterJsonDecoder`) and downstream decoders (`CsvMappedDecoder`, `CsvMappedBatchDecoder`).

- [ ] **2. Asynchronous Encoding Throughput Optimizations & Pre-Async Flush Validation Across Serializers**
  - **Idea**: Systematically maximize throughput, eliminate unneeded `Future` allocations on synchronous fast paths, and audit/validate deterministic pre-async flushes across all encoders (`jsonEncodeAsync`, `jsonlEncodeAsync`, `csvEncodeAsync`, `csvEncodeBatchAsync`, `jsonlEncodeBatchAsync`).
  - **Context**: In streaming pipelines, large collections are frequently serialized where the majority of rows, objects, or fields are already in memory and synchronous. Previous implementations awaited every element, allocating a `Future` per item and repeatedly context-switching across event loop turns. Additionally, when encoders buffer output in memory (via `BufferedStringSink`), failing to flush before an asynchronous pause (`await`) starves downstream consumers. We initiated a multi-phase optimization effort:
    - [x] Landed PR #336: Enhanced `iterateStreamOrIterable` to return a nullable `Future<void>?`, allowing synchronous collections to complete without allocating a `Future` or yielding to the event loop.
    - [x] Landed PR #337: Synchronous row fast path and pre-async flush in `csvEncodeAsync`.
    - [x] Landed: Write batching via `BufferedStringSink` in `jsonlEncodeAsync`.
    - [ ] In Review (PR #339): Synchronous fast path and comprehensive pre-async flush for primitives, maps, and iterables in `jsonEncodeAsync`.
  - **Investigation**:
    1. *Comprehensive Pre-Async Flush Audit across Encoders*:
       - **JSON (`jsonEncodeAsync`)**:
         - [x] Pre-async flush before awaiting nested `Future` values.
         - [x] Pre-async flush before awaiting `Future` map keys (`resumeMapFromKeyAsync`).
         - [x] Pre-async flush before awaiting `Future` map values (`resumeMapFromValueAsync`).
         - [x] Pre-async flush before awaiting child items when resuming `Iterable` traversal (`resumeIterableAsync`).
         - [x] Pre-async flush before awaiting incoming stream events in `Stream` arrays (`encodeStreamAsync`).
         - [x] Pre-async flush before awaiting `AsyncJsonWritable.writeJsonAsync`.
         - [x] Pre-async flush before awaiting async `toJson()` results.
       - **CSV (`csvEncodeAsync`, `csvEncodeBatchAsync`)**:
         - [x] Pre-async flush before awaiting row-level `Future`s (`rawRow is Future`, `toCsv() is Future`).
         - [x] Pre-async flush before awaiting cell-level `Future`s within a row (`writeRemainingCellsAsync`).
         - [x] Pre-async flush between stream events via `onStreamItemDone: activeSink.flush`.
         - [ ] Validate and audit `csvEncodeBatchAsync` to ensure chunk flushes propagate before batch boundary awaits.
       - **JSONL (`jsonlEncodeAsync`, `jsonlEncodeBatchAsync`)**:
         - [ ] Introduce synchronous fast path in `jsonlEncodeAsync` to avoid `(item) async` closure allocation per item when items and `jsonEncodeAsync` are synchronous.
         - [ ] Validate pre-async flush before awaiting `Future` items in `jsonlEncodeAsync`.
         - [ ] Validate pre-async flush before awaiting async `jsonEncodeAsync` execution.
         - [ ] Audit `jsonlEncodeBatchAsync` to guarantee batch flushes propagate before awaiting downstream sink operations.
    2. *Benchmark & Quantify*: Build benchmark suites comparing allocation counts, microtask queue depth, and throughput for purely synchronous collections, fully asynchronous streams, and mixed async payloads across all encoders.
    3. *Buffer Pooling & Sizing*: Investigate buffer reuse or adaptive sizing in `BufferedStringSink` to reduce heap allocations during multi-megabyte stream serialization.
    4. *Direct Byte Sink Integration*: Explore direct encoding into `ChunkedConversionSink<List<int>>` or `Utf8StreamStringSink` to avoid intermediate UTF-16 string allocations.
