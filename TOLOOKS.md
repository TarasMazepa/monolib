# ToLooks

- [ ] **1. Generic JSON Selector Converter for Streaming Pipelines (`JsonMappedConverter`)**
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
