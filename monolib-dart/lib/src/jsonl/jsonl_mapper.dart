import 'dart:convert';
import 'jsonl_mapper_sink_internal.dart';

/// A Converter that parses JSON and maps to a strongly typed model,
/// dropping nulls along the way. Designed to be fused with LineSplitter.
class JsonlMapper<T> extends Converter<String, T> {
  final T? Function(dynamic) fromJson;
  final bool ignoreExceptions;

  const JsonlMapper(this.fromJson, {this.ignoreExceptions = false});

  @override
  T convert(String input) {
    throw UnsupportedError('This converter only supports chunked conversion');
  }

  @override
  Sink<String> startChunkedConversion(Sink<T> sink) {
    return JsonlMapperSinkInternal<T>(sink, fromJson,
        ignoreExceptions: ignoreExceptions);
  }
}
