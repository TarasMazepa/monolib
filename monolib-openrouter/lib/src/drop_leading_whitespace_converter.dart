import 'dart:convert';

import 'package:monolib_dart/stream.dart';

/// A [Converter] that strips leading ASCII whitespace bytes (0x20, 0x0A, 0x0D, 0x09)
/// from a byte stream before passing data downstream.
///
/// Architecturally, this class prevents JSON parse errors when handling streaming
/// responses from LLM APIs (such as OpenRouter) that may eagerly send keep-alive
/// pings (e.g., `\r\n`) or other padding bytes prior to transmitting the actual
/// JSON body. By actively filtering these out, it guarantees that downstream
/// decoders receive a clean starting token.
///
/// This is typically used in front of a [utf8.decoder] and [JsonDecoder] within
/// an HTTP response stream pipeline.
///
/// Example:
/// ```dart
/// final pipeline = responseStream.transform(
///   const DropLeadingWhitespaceConverter()
///       .fuse(utf8.decoder)
///       .fuse(json.decoder),
/// );
/// ```
class DropLeadingWhitespaceConverter extends Converter<List<int>, List<int>> {
  /// Called when adding a chunk to the downstream sink fails.
  ///
  /// Such errors are naturally ignored by the underlying [EventSink] tryAdd
  /// extensions. Without an [onError] callback provided, they are silently dropped.
  final void Function(Object error, StackTrace stackTrace)? onError;

  /// Creates a [DropLeadingWhitespaceConverter] that optionally reports downstream
  /// sink transmission errors to the provided [onError] handler.
  const DropLeadingWhitespaceConverter({this.onError});

  /// Synchronously processes the entire [input] byte array, returning a new slice
  /// starting from the first non-whitespace byte.
  ///
  /// If the [input] consists entirely of whitespace, it returns an empty list.
  @override
  List<int> convert(List<int> input) {
    final index = input.indexWhere(_isNotWhitespace);
    return index == -1 ? const [] : input.sublist(index);
  }

  /// Instantiates and returns a [_DropLeadingWhitespaceConverterSink] for processing
  /// asynchronous streams in a chunked manner, pushing processed data to the
  /// downstream [sink].
  @override
  Sink<List<int>> startChunkedConversion(Sink<List<int>> sink) {
    return _DropLeadingWhitespaceConverterSink(sink, onError: onError);
  }
}

/// Evaluates if a byte [b] is a non-whitespace character.
/// Checks against standard ASCII whitespace: space (0x20), line feed (0x0A),
/// carriage return (0x0D), and tab (0x09).
bool _isNotWhitespace(int b) =>
    b != 0x20 && b != 0x0A && b != 0x0D && b != 0x09;

/// The internal sink for chunked conversion, maintaining state on whether
/// non-whitespace content has been encountered yet.
class _DropLeadingWhitespaceConverterSink
    implements ChunkedConversionSink<List<int>> {
  /// The downstream sink receiving the cleanly trimmed bytes.
  final Sink<List<int>> _outSink;

  /// The error handler corresponding to [DropLeadingWhitespaceConverter.onError].
  final void Function(Object error, StackTrace stackTrace)? _onError;

  /// Tracks whether the initial whitespace trimming sequence has concluded.
  bool _hasSeenContent = false;

  /// Constructs the chunked sink with a target [_outSink] and an optional [onError] callback.
  _DropLeadingWhitespaceConverterSink(
    this._outSink, {
    void Function(Object error, StackTrace stackTrace)? onError,
  }) : _onError = onError;

  /// Ingests a raw byte [chunk]. If content has already been seen, the chunk
  /// is passed blindly. If in trimming mode, it scans for the first non-whitespace
  /// character and forwards the remaining sublist.
  @override
  void add(List<int> chunk) {
    if (_hasSeenContent) {
      _outSink.tryAdd(chunk, ignoreError: true, onError: _onError);
    } else {
      final index = chunk.indexWhere(_isNotWhitespace);
      if (index != -1) {
        _hasSeenContent = true;
        _outSink.tryAdd(
          chunk.sublist(index),
          ignoreError: true,
          onError: _onError,
        );
      }
    }
  }

  /// Concludes the chunked conversion by closing the underlying [_outSink].
  @override
  void close() => _outSink.close();
}
