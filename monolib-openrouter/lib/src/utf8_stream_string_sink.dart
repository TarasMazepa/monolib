import 'dart:async';
import 'dart:convert';

import 'package:monolib_dart/stream.dart';

/// A [StringSink] that UTF-8 encodes everything written to it and adds the
/// resulting bytes to an [EventSink] of bytes.
///
/// Architecturally, [Utf8StreamStringSink] acts as a non-buffering bridge
/// between high-throughput string generators (like `jsonEncodeAsync`) and
/// byte-based networking or file writing endpoints. It immediately translates
/// textual output into UTF-8 chunks without ever accumulating the entire string
/// in memory, which is critical for handling massive JSON responses or streaming
/// LLM outputs directly into an HTTP request body.
///
/// Example:
/// ```dart
/// final controller = StreamController<List<int>>();
/// final stringSink = Utf8StreamStringSink(controller.sink);
///
/// // Encodes iteratively to bytes and adds them directly to the StreamController.
/// await jsonEncodeAsync({'large': 'payload...'}, stringSink);
/// ```
class Utf8StreamStringSink implements StringSink {
  final EventSink<List<int>> _sink;
  final void Function(Object error, StackTrace stackTrace)? _onError;

  /// Creates a [Utf8StreamStringSink] that wraps the underlying byte [_sink].
  ///
  /// The [_sink] is typically the endpoint for the encoded data (e.g. an
  /// `IOSink` or the `sink` of a `StreamController<List<int>>`).
  ///
  /// The [onError] callback is invoked if adding encoded bytes to [_sink] throws
  /// an exception (handled safely via [OnSink.tryAdd]). Such errors are caught
  /// internally to prevent pipeline crashes; if [onError] is omitted, they are
  /// silently dropped.
  const Utf8StreamStringSink(
    this._sink, {
    void Function(Object error, StackTrace stackTrace)? onError,
  }) : _onError = onError;

  /// Converts the given [object] to its string representation and immediately
  /// UTF-8 encodes it, emitting the raw bytes to the underlying sink.
  ///
  /// Uses [OnSink.tryAdd] to safely dispatch the bytes, ensuring the process
  /// does not crash if the target sink is closed or throws a `StateError`.
  @override
  void write(Object? object) {
    _sink.tryAdd(utf8.encode('$object'), ignoreError: true, onError: _onError);
  }

  /// Iterates over [objects], writing each one to the underlying sink sequentially,
  /// optionally interleaved with the provided [separator].
  ///
  /// This method is memory-efficient as it does not buffer the entire [Iterable]
  /// nor concatenate it into a single large string. Each element is encoded and
  /// flushed individually via [write].
  @override
  void writeAll(Iterable<dynamic> objects, [String separator = '']) {
    final iterator = objects.iterator;
    if (!iterator.moveNext()) return;
    if (separator.isEmpty) {
      do {
        write(iterator.current);
      } while (iterator.moveNext());
    } else {
      write(iterator.current);
      while (iterator.moveNext()) {
        write(separator);
        write(iterator.current);
      }
    }
  }

  /// Converts a single Unicode [charCode] into a single-character string, UTF-8
  /// encodes it, and emits the bytes to the underlying sink.
  @override
  void writeCharCode(int charCode) {
    _sink.tryAdd(
      utf8.encode(String.fromCharCode(charCode)),
      ignoreError: true,
      onError: _onError,
    );
  }

  /// Writes the string representation of [object] followed by a newline `\n`
  /// character to the underlying sink.
  ///
  /// If [object] is omitted, it defaults to an empty string, effectively
  /// just writing the newline character.
  @override
  void writeln([Object? object = '']) {
    write(object);
    write('\n');
  }
}
