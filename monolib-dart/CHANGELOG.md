## 0.0.42

- Complete API symmetry for JSONL decoders by propagating `jsonCodec` through `JsonlMappedDecoder` and `JsonlMappedBatchDecoder`, allowing custom JSON decoders to be injected.

## 0.0.41

- Added `always_use_package_imports` lint rule and applied it project-wide.
- DRY up in-memory `CsvDecoder` and `JsonlDecoder` by delegating structural parsing to their respective chunked decoders.
- Extract `BatchingSinkMixin` to remove batching boilerplate from mapped batch decoders.
- Extract `iterateStreamOrIterable` to consolidate stream/iterable iteration in async encoders.

## 0.0.40

- Performs DRY cleanup on JSONL decoders by moving line sanitization (stripping carriage returns and empty line checks) directly into `JsonlBaseChunkSink`.

## 0.0.39

- **BREAKING:** Removed `csvEncodeAsyncForIOSink`, `jsonlEncodeAsyncForIOSink`, and `jsonEncodeAsyncForIOSink` utilities.
- Extracts duplicated CSV cell escaping logic into `csv_cell_writer.dart` to DRY up encoders.

## 0.0.38

- Performs massive DRY refactoring on chunked decoders by extracting duplicated structural parsing logic into `CsvBaseChunkSink` and `JsonlBaseChunkSink`.

## 0.0.37

- Extracts duplicate `convert` implementation from chunked decoders into a common `ChunkedOnlyConverter` base class.
- Resolves internal private sink naming collisions for mapped CSV decoders.

## 0.0.36

- Renames `CsvRowDecoder` to `CsvChunkedDecoder` and `JsonlMapper` to `JsonlChunkedDecoder` to complete the decoder API matrix unification.
- Rewrites `JsonlChunkedDecoder` to handle its own chunk boundary line splitting, maximizing performance.

## 0.0.35

- Adds `CsvMappedBatchDecoder` and `JsonlMappedBatchDecoder` for high-throughput batch-emitting stream optimizations.
- Renames `MappedCsvRowDecoder` to `CsvMappedDecoder` and `JsonlSplitMapper` to `JsonlMappedDecoder` to unify naming conventions.

## 0.0.34

- Adds `JsonlSplitMapper` converter that fuses line-splitting directly into JSON mapping, eliminating intermediate stream event overhead.

## 0.0.33

- Refactors `MappedCsvRowDecoder` and `CsvRowDecoder` to use synchronous `StreamController` instead of `Stream.multi` to preserve standard stream contracts and lifecycle hooks.

## 0.0.32

- Guarantees `jsonlEncodeAsync` outputs a trailing newline even if item serialization throws an error.
- **BREAKING:** Removes `OnFunctionWithOneArgument` (`withAnArgument`).
- **BREAKING:** Removes `asArgumentIn` and `quotingString` from `OnObject`.

## 0.0.31

- Adds `mapLists` and `whereElements` to `OnStreamOfLists` extension on `Stream<List<T>>`.
- Adds `OnIterableOfNullableBoolFunctions` extension with `combinedEvery` and `combinedAny`.
- Moves `OnNullableString` extension with `emptyToNull` into `on_nullable_string.dart`.
- Enhances `Batcher` documentation and streamlines internal batch tracking.
- **BREAKING:** Removes `mapCatching` from `OnIterable`.
- **BREAKING:** Removes `compareChainReverse` from `OnBool`.
- **BREAKING:** Removes `discardedByFloor` from `OnDouble`.
- **BREAKING:** Removes `OnIterableOfListOfString` (`skipFirstIfIsCsvHeaderRow`).
- **BREAKING:** Removes `OnListOfString` (`isTrimmedDeepEqualsTo`).
- **BREAKING:** Removes `OnString` (`removeEndingNewLine`, `ensureEndsWithADot`, `removeEnclosingQuotationMarks`).
- **BREAKING:** Removes `NullIOSink`.
- **BREAKING:** Removes `OnFunctionReturningList` (`asSkippingMappedToEmptyExpander`).

## 0.0.30

- Adds `JsonlBatchWriter` component to efficiently write high-frequency data to a JSONL file in batches.

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
