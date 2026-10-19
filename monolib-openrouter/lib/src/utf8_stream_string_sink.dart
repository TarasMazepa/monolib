import 'dart:async';
import 'dart:convert';

import 'package:monolib_dart/stream.dart';

/// A [StringSink] that UTF-8 encodes written strings and forwards the resulting
/// byte chunks to an underlying [EventSink].
///
/// Bridges string-producing APIs (such as `jsonEncodeAsync`) directly to
/// byte-based sinks without buffering the entire string in memory.
///
/// Example:
/// ```dart
/// final controller = StreamController<List<int>>();
/// final stringSink = Utf8StreamStringSink(controller.sink);
///
/// // Encodes iteratively to bytes and adds them directly to the StreamController.
/// await jsonEncodeAsync(object: {'large': 'payload...'}, sink: stringSink);
/// ```
class Utf8StreamStringSink implements StringSink {
  /// The target endpoint for UTF-8 encoded bytes.
  final EventSink<List<int>> _sink;

  /// An optional callback invoked if the underlying sink throws an exception.
  final void Function(Object error, StackTrace stackTrace)? _onError;

  /// Creates a [Utf8StreamStringSink] that forwards UTF-8 encoded bytes to the
  /// underlying sink.
  ///
  /// The underlying sink is typically an `IOSink` or the `sink` of an internal
  /// [StreamController].
  ///
  /// The [onError] callback is invoked if adding encoded bytes to the
  /// underlying sink throws an error (handled via [OnSink.tryAdd]). If
  /// [onError] is omitted, such errors are silently ignored.
  const Utf8StreamStringSink(
    this._sink, {
    void Function(Object error, StackTrace stackTrace)? onError,
  }) : _onError = onError;

  /// Converts [object] to a string, UTF-8 encodes it, and emits the resulting
  /// bytes to the underlying sink.
  ///
  /// Uses [OnSink.tryAdd] so writing does not throw if the target sink is
  /// closed or throws a [StateError].
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
