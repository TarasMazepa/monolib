import 'dart:convert';

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
}
