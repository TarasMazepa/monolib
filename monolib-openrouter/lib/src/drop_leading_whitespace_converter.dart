import 'dart:convert';

import 'package:monolib_dart/stream.dart';

/// A [Converter] that strips leading ASCII whitespace bytes (0x20, 0x0A, 0x0D, 0x09)
/// from a byte stream before passing data downstream.
///
/// This is useful in front of a [JsonDecoder] for responses that are padded
/// with leading whitespace, e.g. keep-alive new lines sent before the body.
class DropLeadingWhitespaceConverter extends Converter<List<int>, List<int>> {
  /// Called when adding a chunk to the downstream sink fails.
  ///
  /// Such errors are ignored, so without [onError] they are silently dropped.
  final void Function(Object error, StackTrace stackTrace)? onError;

  /// Creates a [DropLeadingWhitespaceConverter] that reports downstream sink
  /// errors to [onError].
  const DropLeadingWhitespaceConverter({this.onError});

  @override
  List<int> convert(List<int> input) {
    final index = input.indexWhere(_isNotWhitespace);
    return index == -1 ? const [] : input.sublist(index);
  }

  @override
  Sink<List<int>> startChunkedConversion(Sink<List<int>> sink) {
    return _DropLeadingWhitespaceConverterSink(sink, onError: onError);
  }
}

bool _isNotWhitespace(int b) =>
    b != 0x20 && b != 0x0A && b != 0x0D && b != 0x09;

class _DropLeadingWhitespaceConverterSink
    implements ChunkedConversionSink<List<int>> {
  final Sink<List<int>> _outSink;
  final void Function(Object error, StackTrace stackTrace)? _onError;
  bool _hasSeenContent = false;

  _DropLeadingWhitespaceConverterSink(
    this._outSink, {
    void Function(Object error, StackTrace stackTrace)? onError,
  }) : _onError = onError;

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

  @override
  void close() => _outSink.close();
}
