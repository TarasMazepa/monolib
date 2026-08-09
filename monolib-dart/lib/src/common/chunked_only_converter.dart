import 'dart:convert';

/// A base class for converters that strictly operate on streams/chunks.
abstract class ChunkedOnlyConverter<S, T> extends Converter<S, T> {
  const ChunkedOnlyConverter();

  @override
  T convert(S input) {
    throw UnsupportedError('This converter only supports chunked conversion');
  }
}
