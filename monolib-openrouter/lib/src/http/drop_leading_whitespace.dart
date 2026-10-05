import 'dart:convert';

import 'package:monolib_dart/stream.dart';

/// A [Converter] that strips leading ASCII whitespace bytes (0x20, 0x0A, 0x0D, 0x09)
/// from a byte stream before passing data downstream.
class DropLeadingWhitespace extends Converter<List<int>, List<int>> {
  const DropLeadingWhitespace();

  @override
  List<int> convert(List<int> input) {
    final index = input.indexWhere(
      (b) => b != 0x20 && b != 0x0A && b != 0x0D && b != 0x09,
    );
    return index == -1 ? const [] : input.sublist(index);
  }

  @override
  Sink<List<int>> startChunkedConversion(Sink<List<int>> sink) {
    return _DropLeadingWhitespaceSink(sink);
  }
}

class _DropLeadingWhitespaceSink implements ChunkedConversionSink<List<int>> {
  final Sink<List<int>> _outSink;
  bool _hasSeenContent = false;

  _DropLeadingWhitespaceSink(this._outSink);

  @override
  void add(List<int> chunk) {
    if (_hasSeenContent) {
      _outSink.tryAdd(chunk, ignoreError: true);
    } else {
      final index = chunk.indexWhere(
        (b) => b != 0x20 && b != 0x0A && b != 0x0D && b != 0x09,
      );
      if (index != -1) {
        _hasSeenContent = true;
        _outSink.tryAdd(
          chunk.sublist(index),
          ignoreError: true,
        );
      }
    }
  }

  @override
  void close() => _outSink.close();
}
