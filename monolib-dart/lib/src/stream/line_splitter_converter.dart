import 'dart:convert';

import 'package:monolib_dart/src/stream/on_stream_of_list_of_int.dart';

/// A [Converter] adapter around Dart's [LineSplitter] for chunked string
/// conversion.
///
/// Because [LineSplitter] is a `StreamTransformer` rather than a [Converter],
/// it cannot be passed directly to [Converter.fuse]. [LineSplitterConverter]
/// wraps [LineSplitter.startChunkedConversion] as a [Converter] so it can be
/// fused with other converters such as `utf8.decoder` (see
/// [OnStreamOfListOfInt.utf8DecodeAndLineSplit]).
///
/// Example:
/// ```dart
/// final fusedConverter = utf8.decoder.fuse(const LineSplitterConverter());
/// final lineStream = File('data.csv').openRead().transform(fusedConverter);
/// ```
class LineSplitterConverter extends Converter<String, String> {
  /// Creates a constant [LineSplitterConverter].
  const LineSplitterConverter();

  /// Always throws an [UnsupportedError] because this converter only supports
  /// chunked conversion via [startChunkedConversion].
  @override
  String convert(String input) {
    throw UnsupportedError('This converter only supports chunked conversion');
  }

  /// Starts a chunked conversion that splits incoming string chunks into
  /// individual lines and forwards them to [sink].
  @override
  Sink<String> startChunkedConversion(Sink<String> sink) {
    return const LineSplitter().startChunkedConversion(sink);
  }
}
