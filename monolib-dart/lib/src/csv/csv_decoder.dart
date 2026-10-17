/// Provides [CsvDecoder], a synchronous converter for parsing RFC 4180
/// compliant Comma-Separated Values (CSV) strings into lists of rows.
library;

import 'dart:convert';

import 'package:monolib_dart/src/common/list_accumulator_sink.dart';
import 'package:monolib_dart/src/csv/csv_chunked_decoder.dart';

/// A synchronous [Converter] that decodes a full RFC 4180 CSV [String] into a
/// sequence of rows, where each row is a [List] of [String] cells.
///
/// This class serves as the concrete decoding implementation for [CsvCodec.decoder].
/// To avoid duplicating the RFC 4180 parsing state machine, it DRYs up the
/// implementation by delegating the actual structural parsing to [CsvChunkedDecoder].
///
/// It aggregates the synchronous events emitted by the chunked decoder using a
/// [ListAccumulatorSink], completely buffering the result before returning.
///
/// Example:
/// ```dart
/// const decoder = CsvDecoder();
/// final rows = decoder.convert('id,name\n1,"Alice"');
/// print(rows); // [['id', 'name'], ['1', 'Alice']]
/// ```
class CsvDecoder extends Converter<String, List<List<String>>> {
  /// Creates a stateless [CsvDecoder].
  ///
  /// Since the decoder maintains no internal state between conversions,
  /// a single `const` instance can be safely reused to parse multiple
  /// disparate CSV strings.
  const CsvDecoder();

  /// Synchronously transforms a complete CSV string [items] into a
  /// sequence of parsed rows.
  ///
  /// Internally, this sets up a [ListAccumulatorSink] and pipes the entire
  /// [items] payload through [CsvChunkedDecoder.startChunkedConversion].
  ///
  /// If the [items] string is empty, this returns an empty list. If the
  /// payload contains malformed CSV syntax, any underlying formatting
  /// exceptions raised by the chunked decoder will bubble up synchronously.
  @override
  List<List<String>> convert(String items) {
    final sink = ListAccumulatorSink<List<String>>();
    const CsvChunkedDecoder().startChunkedConversion(sink)
      ..add(items)
      ..close();
    return sink.results;
  }
}
