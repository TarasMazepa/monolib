import 'dart:convert';

import 'package:monolib_dart/src/stream/line_splitter_batch_converter.dart';
import 'package:monolib_dart/src/stream/line_splitter_converter.dart';

/// Extension on byte streams (`Stream<List<int>>`) for UTF-8 decoding and line
/// splitting.
extension OnStreamOfListOfInt on Stream<List<int>> {
  /// Decodes this byte stream as UTF-8, splits it into lines, and returns the
  /// first line.
  ///
  /// Transforms the stream using [Utf8Codec.decoder] (`utf8.decoder`) and
  /// [LineSplitter], then resolves with the first emitted line and cancels the
  /// subscription.
  ///
  /// Throws a [StateError] if the stream completes without emitting any lines.
  ///
  /// Example:
  /// ```dart
  /// final fileStream = File('config.txt').openRead();
  /// final header = await fileStream.readLine();
  /// print('File header is: $header');
  /// ```
  Future<String> readLine() {
    return cast<List<int>>()
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .first;
  }

  /// Decodes this byte stream as UTF-8 and splits it into individual text
  /// lines.
  ///
  /// Fuses [Utf8Codec.decoder] (`utf8.decoder`) with [LineSplitterConverter]
  /// via [Converter.fuse] so byte chunks are decoded and split in a single
  /// fused transformation.
  ///
  /// Returns a [Stream] of lines without their trailing newline characters
  /// (`\n` or `\r\n`).
  ///
  /// Example:
  /// ```dart
  /// final process = await Process.start('tail', ['-f', 'server.log']);
  /// await for (final line in process.stdout.utf8DecodeAndLineSplit()) {
  ///   print('Log entry: $line');
  /// }
  /// ```
  Stream<String> utf8DecodeAndLineSplit() {
    return cast<List<int>>().transform(
      utf8.decoder.fuse(const LineSplitterConverter()),
    );
  }

  /// Decodes this byte stream as UTF-8 and emits parsed lines in per-chunk
  /// batches (`List<String>`).
  ///
  /// Fuses [Utf8Codec.decoder] (`utf8.decoder`) with
  /// [LineSplitterBatchConverter] to convert this stream of UTF-8 byte chunks
  /// directly into batches of lines with minimized stream event overhead.
  ///
  /// Optionally invokes [onBatch] before each batch is emitted and [onDone]
  /// when the stream completes.
  ///
  /// Example:
  /// ```dart
  /// final fileStream = File('large_data.txt').openRead();
  /// await for (final batch in fileStream.utf8DecodeAndLineSplitBatch()) {
  ///   await processLines(batch);
  /// }
  /// ```
  Stream<List<String>> utf8DecodeAndLineSplitBatch({
    void Function(List<String> batch)? onBatch,
    void Function()? onDone,
  }) {
    return cast<List<int>>().transform(
      utf8.decoder.fuse(
        LineSplitterBatchConverter<String>(
          onBatch: onBatch,
          onDone: onDone,
        ),
      ),
    );
  }

  /// Decodes this byte stream as UTF-8, maps each parsed line using [mapper],
  /// and emits non-null results in per-chunk batches (`List<T>`).
  ///
  /// Fuses [Utf8Codec.decoder] (`utf8.decoder`) with
  /// [LineSplitterBatchConverter.mapped] to convert this stream of UTF-8 byte
  /// chunks directly into batches of domain objects with minimized stream event
  /// overhead.
  ///
  /// Optionally invokes [onBatch] before each batch is emitted and [onDone]
  /// when the stream completes.
  ///
  /// Example:
  /// ```dart
  /// final fileStream = File('ids.txt').openRead();
  /// final idBatches = fileStream.utf8DecodeAndLineSplitMappedBatch((line) {
  ///   return int.tryParse(line);
  /// });
  /// await for (final batch in idBatches) {
  ///   await fetchUsersByIds(batch);
  /// }
  /// ```
  Stream<List<T>> utf8DecodeAndLineSplitMappedBatch<T>(
    T? Function(String line) mapper, {
    void Function(List<T> batch)? onBatch,
    void Function()? onDone,
  }) {
    return cast<List<int>>().transform(
      utf8.decoder.fuse(
        LineSplitterBatchConverter<T>.mapped(
          mapper,
          onBatch: onBatch,
          onDone: onDone,
        ),
      ),
    );
  }
}
