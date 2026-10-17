/// Utilities for processing raw byte streams, focusing on high-performance
/// text decoding and line splitting operations.
library;

import 'dart:convert';

import 'package:monolib_dart/src/stream/line_splitter_converter.dart';

/// A high-performance byte-stream processing pipeline for bridging raw I/O to text architectures.
///
/// When ingesting massive datasets from `dart:io` (such as file reads, network responses,
/// or continuous `stdin`), the raw output is always a chunked `Stream<List<int>>`. Translating
/// these disparate byte chunks into meaningful string lines traditionally requires manually
/// fusing `utf8.decoder` and `LineSplitter`, which adds boilerplate and mental overhead to
/// data-ingestion systems.
///
/// This extension provides optimized, single-call pipeline transformations that abstract away
/// intermediate string allocations and chunk buffering, enabling clean, memory-efficient
/// streaming from raw bytes directly to domain-level string manipulation.
extension OnStreamOfListOfInt on Stream<List<int>> {
  /// Asynchronously reads the first available text line from the byte stream,
  /// automatically handling UTF-8 decoding and line splitting.
  ///
  /// This method transforms the byte chunks using [Utf8Codec.decoder] (`utf8.decoder`) and [LineSplitter],
  /// resolving with the first emitted string before automatically canceling the
  /// underlying stream subscription. It is specifically designed as a non-blocking
  /// alternative for scenarios like reading prompts from standard input where
  /// synchronous APIs (like `stdin.readLineSync()`) would inappropriately block
  /// the event loop.
  ///
  /// Throws a [StateError] if the stream is empty or completes without yielding any lines.
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

  /// Transforms the raw byte stream into a continuous stream of decoded text lines.
  ///
  /// Because Dart's core [LineSplitter] is purely a [StreamTransformer] and not a [Converter],
  /// it cannot be directly passed to [Converter.fuse]. To solve this, this method uses
  /// the repository's custom [LineSplitterConverter], which allows it to fuse with
  /// [Utf8Codec.decoder] (`utf8.decoder`). This fusion optimizes the pipeline by skipping intermediate string
  /// allocations during the transformation phase, dramatically improving performance for
  /// large text processing.
  ///
  /// Returns a new [Stream] where each event is a discrete line of text, stripped of
  /// its terminating newline sequences (like `\r\n` or `\n`).
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
}
