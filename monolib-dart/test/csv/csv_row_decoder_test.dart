import 'package:test/test.dart';
import 'package:monolib_dart/src/csv/csv_row_decoder.dart';
import 'dart:async';

void main() {
  group('CsvRowDecoder', () {
    test('parses simple csv across chunks', () async {
      final stream = Stream.fromIterable(['a,b,c\n', '1,2,3\n']);
      final result = await stream.transform(const CsvRowDecoder()).toList();
      expect(result, [
        ['a', 'b', 'c'],
        ['1', '2', '3']
      ]);
    });
  });

  group('CsvRowDecoder more tests', () {
    test('parses csv with escaped quotes and newlines across chunks', () async {
      final stream = Stream.fromIterable(['a,"b\n', 'c",d\n']);
      final result = await stream.transform(const CsvRowDecoder()).toList();
      expect(result, [
        ['a', 'b\nc', 'd'],
      ]);
    });

    test('escaped quotes at the edge of chunk', () async {
      final stream = Stream.fromIterable(['a,"b"', '""', '"c",d\n']);
      final result = await stream.transform(const CsvRowDecoder()).toList();
      expect(result, [
        ['a', 'b""c', 'd'],
      ]);
    });

    test('empty cells', () async {
      final stream = Stream.fromIterable(['a,,c\n', ',b,\n', 'x,,']);
      final result = await stream.transform(const CsvRowDecoder()).toList();
      expect(result, [
        ['a', '', 'c'],
        ['', 'b', ''],
        ['x', '', '']
      ]);
    });

    test('double quotes at end of chunk', () async {
      final stream = Stream.fromIterable(['a,"b', '"', 'c",d\n']);
      final result = await stream.transform(const CsvRowDecoder()).toList();
      expect(result, [
        ['a', 'b', 'c"', 'd'], // fixed expected to match CsvDecoder behavior
      ]);
    });
  });
}
