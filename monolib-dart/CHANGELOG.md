## 0.0.29

- Adds `AsyncJsonWritable` interface for providing inversion-of-control when encoding objects asynchronously in `jsonEncodeAsync`.
- Adds `StreamingJsonString` which allows streaming strings directly into the output sink without holding them in memory.

## 0.0.28

- **BREAKING:** Removes `jsonEncodeAsyncForIOSinkProvider` and `jsonlEncodeAsyncForIOSinkProvider`.
- Refactors `jsonlEncodeAsync` to use a `late` variable for sink initialization.
- Cleans up and sorts exports in `fluent_json.dart`, `monolib_dart.dart`, and `stream.dart`.

## 0.0.27

- **BREAKING:** Updates signatures for async JSON/JSONL encoders (`jsonEncodeAsync`, `jsonlEncodeAsync`) to use named arguments (`items`, `sink`, `sinkProvider`).
- Introduces lazy initialization via `sinkProvider` for async encoders. Sinks are now memoized and only spun up upon the first write operation, saving resources for empty streams/iterables.
- Adds automatic resource cleanup (`close()`) for sinks spawned by `sinkProvider`, while respecting caller ownership for directly provided sinks.
- Adds `jsonEncodeAsyncForIOSinkProvider` and `jsonlEncodeAsyncForIOSinkProvider` to support lazy `IOSink` resolution.

## 0.0.26

- Adds `JsonlMapper` and `JsonlMapperSinkInternal` for mapping JSON from chunked JSONL strings.
- Fuses utf8 decoding with line splitting in `utf8DecodeAndLineSplit` extension on `Stream<List<int>>`.

## 0.0.25

- Adds `MappedCsvRowDecoder` for streaming asynchronous chunked CSV parsing with mapping and filtering support.

## 0.0.24

- Adds `LazyJson` class to defer JSON evaluation.

## 0.0.23

- Adds `StreamWhereTypeExtension` with `whereType<R>()` method to `Stream`.
- Adds `MapNotNullStreamExtension` with `mapNotNull<R>()` method to `Stream`.

## 0.0.22

- Adds `CsvRowDecoder` for streaming asynchronous chunked CSV parsing.
- Adds rfc4180 compatibility parity tests for Csv encoders/decoders.

## 0.0.21

- Adds `Iso8601WithTimeZone` extension on `DateTime` with `toIso8601StringWithTz` method.

## 0.0.20

- Adds `Flag` and related models (`FlagFindResult`, `FlagFindType`, `OptionalFlagResult`) for parsing CLI arguments to `cli.dart`.

## 0.0.19

- Adds Zalgo encoding and decoding functions

## 0.0.18

- CsvDecoder - ensuring that no empty lists would be output at the end of the csv list of lists

## 0.0.17

- Enhances `Batcher` with proper asynchronous disposal (waits for all in-flight batches) and allows nullable limits (`maxBatchSize` / `maxDuration`). Adds `throwOnAddAfterDispose` configuration flag.
- Adds `OnStreamOfListOfInt` extension on `Stream<List<int>>` with `readLine()` and `utf8DecodeAndLineSplit()`.

## 0.0.16

- Adds `jsonEncodeAsyncForIOSink`, `jsonlEncodeAsyncForIOSink`, and `csvEncodeAsyncForIOSink`

## 0.0.15

- Adds `csvEncodeAsync` asynchronous CSV stream encoder
- Adds `OnFutureFunction` extension with `asyncCallWithRetryOnFailure` and `asyncRetryOnFailure` global function

## 0.0.14

- Adds `withIOSink` to `IOSink`

## 0.0.13

- Adds `withIOSink` to `IOSink Function()`

## 0.0.12

- Actually adds jsonlEncodeAsync

## 0.0.11

- Adds jsonlEncodeAsync

## 0.0.10

- Adds `toExtendedRadixString` extension method to `int`
- Removes `min()` and `max()` extension methods

## 0.0.9

- Adds `OnString.parseAsFluentJson` extension
- Adds CSV codec and extensions
- Adds `OnDouble`, `OnFunctionWithNoArguments`, `OnFunctionWithOneArgument`, `OnIterableOfNum`, `OnListOfLists`, and `OnString` extensions.
- Adds `TableCellAlignLeft` and `TableCellAlignRight` for table formatting.



## 0.0.8

- Fixes ConcurrentModificationError in PillarChangeNotifier during notification.
- Extracts PillarChangeNotifierInternal into a separate file.

## 0.0.7

- Adds `JsonlCodec`
- Adds `OnIterableOfStreamControllers`
- Adds `OnFunctionReturningList`
- Adds `OnListOfStreamControllers`
- Adds `OnStreamController`
- Adds `OnStreamOfLists`
- Adds `SingleValueCachingStream`
- Adds `StreamWithClose`

## 0.0.6

- Adds `NullIOSink`

## 0.0.5

- Changes `jsonEncodeAsync` signature to use `Object?` instead of `dynamic`

## 0.0.4

- Adds `jsonEncodeAsync` streaming JSON encoder

## 0.0.3

- Adds various extension methods
- Adds FluentJson

## 0.0.2

## 0.0.1

## 0.0.0

- Initial version.
