import 'dart:convert';
import 'jsonl_mapper_sink_internal.dart';

/// A Converter that parses JSON and maps to a strongly typed model,
/// dropping nulls along the way. Designed to be fused with LineSplitter.
class JsonlMapper<T> extends Converter<String, T> {
  final T? Function(dynamic) fromJson;

  const JsonlMapper(this.fromJson);

  @override
  T convert(String input) {
    // Required by the interface for synchronous conversion
    final mapped = fromJson(jsonDecode(input));
    if (mapped == null) throw StateError('Mapped to null');
    return mapped;
  }

  @override
  Sink<String> startChunkedConversion(Sink<T> sink) {
    return JsonlMapperSinkInternal<T>(sink, fromJson);
  }
}
