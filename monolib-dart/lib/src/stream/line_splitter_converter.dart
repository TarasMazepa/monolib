import 'dart:convert';

import 'package:monolib_dart/src/stream/on_stream_of_list_of_int.dart';

/// An architectural adapter that wraps Dart's native [LineSplitter] into
/// the [Converter] interface.
///
/// In Dart's standard library, [LineSplitter] is a `StreamTransformer`, not a
/// `Converter`. Because of this, it cannot be directly composed with other
/// decoders using [Converter.fuse] (such as `utf8.decoder.fuse()`).
///
/// [LineSplitterConverter] solves this limitation by bridging the native chunked
/// conversion logic of [LineSplitter] into the expected [Converter] signature.
/// This allows developers to build highly optimized, unified decoding pipelines
/// that seamlessly transition from raw bytes directly to individual text lines
/// (see [OnStreamOfListOfInt.utf8DecodeAndLineSplit]).
///
/// ### Example
/// ```dart
/// // Fusing UTF-8 decoding with line splitting into a single Converter.
/// final fusedConverter = utf8.decoder.fuse(const LineSplitterConverter());
///
/// // Stream raw bytes directly to lines.
/// final lineStream = File('data.csv').openRead().transform(fusedConverter);
/// ```
class LineSplitterConverter extends Converter<String, String> {
  /// Creates a constant [LineSplitterConverter].
  ///
  /// This adapter does not carry any internal state, making it safe to define
  /// as a constant and reuse across multiple stream conversions.
  const LineSplitterConverter();

  /// Synchronous conversion is intentionally unsupported.
  ///
  /// Line splitting is inherently a continuous, chunk-based operation designed
  /// for streaming architectures. Attempting to convert a standalone string
  /// directly via this method throws an [UnsupportedError].
  ///
  /// Throws:
  /// * [UnsupportedError] always, since only chunked conversions are supported.
  @override
  String convert(String input) {
    throw UnsupportedError('This converter only supports chunked conversion');
  }

  /// Initiates a chunked conversion operation by delegating to the native
  /// [LineSplitter.startChunkedConversion].
  ///
  /// This method enables asynchronous bridging. Incoming chunks of strings are
  /// buffered and split by newline characters (`\n` or `\r\n`), then emitted
  /// as individual lines to the target [sink].
  ///
  /// Returns a [Sink] configured to accept string chunks and emit split lines.
  @override
  Sink<String> startChunkedConversion(Sink<String> sink) {
    return const LineSplitter().startChunkedConversion(sink);
  }
}
