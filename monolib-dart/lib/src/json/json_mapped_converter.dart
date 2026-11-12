import 'dart:convert';

import 'package:monolib_dart/src/json/fluent_json.dart';

/// A [Converter] that extracts a target domain object or field of type [T] from
/// decoded JSON structures using a [FluentJson] selector function.
///
/// [JsonMappedConverter] implements chunked conversion so it can be fused
/// directly into streaming pipelines with [Converter.fuse] (for example,
/// downstream of `json.decoder` or `openRouterJsonDecoder`, and upstream of
/// decoders such as `CsvMappedDecoder` or `CsvMappedBatchDecoder`).
///
/// Example:
/// ```dart
/// final pipeline = json.decoder
///     .fuse(JsonMappedConverter<String>(
///       (json) => json['choices'][0]['message'].unboxed<String>('content'),
///     ));
///
/// final stream = Stream.fromIterable([
///   '{"choices":[{"message":{"content":"hello"}}]}',
/// ]);
/// final contentStream = stream.transform(pipeline);
/// await for (final text in contentStream) {
///   print(text); // 'hello'
/// }
/// ```
class JsonMappedConverter<T> extends Converter<dynamic, T> {
  final T Function(FluentJson json) _selector;
  final void Function()? _onDone;

  /// Creates a [JsonMappedConverter] that maps each decoded JSON value using [_selector].
  ///
  /// Optionally invokes [onDone] when the input stream completes and the sink
  /// is closed.
  const JsonMappedConverter(
    this._selector, {
    void Function()? onDone,
  }) : _onDone = onDone;

  /// Converts a single decoded JSON payload [input] into [T] using [_selector].
  ///
  /// If [input] is already a [FluentJson] instance, it is passed directly to
  /// [_selector]. Otherwise, [input] is wrapped with [FluentJson.root].
  @override
  T convert(dynamic input) {
    final fluent = input is FluentJson ? input : FluentJson.root(input);
    return _selector(fluent);
  }

  /// Starts a chunked conversion that maps each incoming decoded JSON chunk
  /// using [_selector] and forwards the resulting [T] value to [sink].
  @override
  Sink<dynamic> startChunkedConversion(Sink<T> sink) {
    return _JsonMappedConverterSink<T>(sink, _selector, onDone: _onDone);
  }
}

/// Internal [ChunkedConversionSink] implementation for [JsonMappedConverter].
class _JsonMappedConverterSink<T> implements ChunkedConversionSink<dynamic> {
  final Sink<T> _outSink;
  final T Function(FluentJson json) _selector;
  final void Function()? _onDone;

  _JsonMappedConverterSink(
    this._outSink,
    this._selector, {
    void Function()? onDone,
  }) : _onDone = onDone;

  @override
  void add(dynamic chunk) {
    final fluent = chunk is FluentJson ? chunk : FluentJson.root(chunk);
    _outSink.add(_selector(fluent));
  }

  @override
  void close() {
    _onDone?.call();
    _outSink.close();
  }
}
