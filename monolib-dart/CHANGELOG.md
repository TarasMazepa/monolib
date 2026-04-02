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
