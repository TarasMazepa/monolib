/// A proxy [StringSink] that buffers written characters in memory and flushes
/// them in chunks to an underlying sink.
///
/// Buffering small writes reduces virtual dispatch, stream event overhead, and
/// I/O operations when targeting byte sinks or streaming destinations (such as
/// `IOSink` or `Utf8StreamStringSink`).
///
/// When the underlying [sink] is already a [BufferedStringSink], that instance
/// is reused to prevent redundant wrapping. When the underlying sink is a
/// [StringBuffer], writes are directed straight into it without intermediate
/// buffering.
///
/// Use [BufferedStringSink.lazy] to defer sink resolution until the first
/// non-empty [flush] occurs, preventing premature allocation of empty sinks or
/// files.
class BufferedStringSink implements StringSink, Sink<String> {
  /// The default maximum buffer size in characters (64 KB).
  static const defaultMaxBufferSize = 64 * 1024;

  final StringSink Function() _getSink;
  late final StringSink _resolvedSink = _getSink();
  final StringBuffer _buffer;

  /// The maximum number of characters to hold in the buffer before flushing.
  final int maxBufferSize;
  final bool _isDirect;

  BufferedStringSink._(
    this._getSink,
    this._buffer, {
    required bool isDirect,
    required this.maxBufferSize,
  }) : _isDirect = isDirect;

  /// Creates a [BufferedStringSink] wrapping [sink].
  ///
  /// Buffers up to [maxBufferSize] characters before automatically flushing to
  /// [sink]. Defaults to [defaultMaxBufferSize].
  factory BufferedStringSink(
    StringSink sink, {
    int maxBufferSize = defaultMaxBufferSize,
  }) {
    if (sink is BufferedStringSink) {
      return sink;
    }
    if (sink is StringBuffer) {
      return BufferedStringSink._(
        () => sink,
        sink,
        isDirect: true,
        maxBufferSize: maxBufferSize,
      );
    }
    return BufferedStringSink._(
      () => sink,
      StringBuffer(),
      isDirect: false,
      maxBufferSize: maxBufferSize,
    );
  }

  /// Creates a [BufferedStringSink] that lazily resolves its target sink via
  /// [getSink] upon the first non-empty [flush].
  ///
  /// Deferring sink creation avoids creating empty files or buffers when no
  /// items are ever written.
  factory BufferedStringSink.lazy(
    StringSink Function() getSink, {
    int maxBufferSize = defaultMaxBufferSize,
  }) {
    return BufferedStringSink._(
      getSink,
      StringBuffer(),
      isDirect: false,
      maxBufferSize: maxBufferSize,
    );
  }

  /// Whether the internal buffer is currently empty.
  bool get isEmpty => _buffer.isEmpty;

  /// Whether the internal buffer contains pending data.
  bool get isNotEmpty => _buffer.isNotEmpty;

  /// The number of characters currently held in the internal buffer.
  int get length => _buffer.length;

  /// Flushes any pending buffered content to the underlying sink.
  void flush() {
    if (!_isDirect && _buffer.isNotEmpty) {
      _resolvedSink.write(_buffer.toString());
      _buffer.clear();
    }
  }

  @override
  void add(String data) {
    write(data);
  }

  @override
  void close() {
    flush();
  }

  @override
  void write(Object? object) {
    _buffer.write(object);
    if (!_isDirect && _buffer.length >= maxBufferSize) {
      flush();
    }
  }

  @override
  void writeAll(Iterable<dynamic> objects, [String separator = '']) {
    _buffer.writeAll(objects, separator);
    if (!_isDirect && _buffer.length >= maxBufferSize) {
      flush();
    }
  }

  @override
  void writeCharCode(int charCode) {
    _buffer.writeCharCode(charCode);
    if (!_isDirect && _buffer.length >= maxBufferSize) {
      flush();
    }
  }

  @override
  void writeln([Object? object = '']) {
    _buffer.writeln(object);
    if (!_isDirect && _buffer.length >= maxBufferSize) {
      flush();
    }
  }
}
