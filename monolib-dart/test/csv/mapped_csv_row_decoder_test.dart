import 'package:test/test.dart';
import 'package:monolib_dart/src/csv/mapped_csv_row_decoder.dart';
import 'dart:async';

void main() {
  group('MappedCsvRowDecoder', () {
    test('parses simple csv across chunks and maps to objects', () async {
      final stream = Stream.fromIterable(['name,age\n', 'John,30\n']);

      String? mapper(List<String> row) {
        if (row.length == 2) {
          return '${row[0]}: ${row[1]}';
        }
        return null;
      }

      final result =
          await stream.transform(MappedCsvRowDecoder(mapper)).toList();
      expect(result, ['name: age', 'John: 30']);
    });

    test('filters rows when mapper returns null', () async {
      final stream = Stream.fromIterable([
        'name,age\n',
        'John,30\n',
        'Jane,notanumber\n',
      ]);

      String? mapper(List<String> row) {
        if (row[0] == 'name') return null; // filter header
        if (int.tryParse(row[1]) == null) return null; // filter invalid age
        return '${row[0]}: ${row[1]}';
      }

      final result =
          await stream.transform(MappedCsvRowDecoder(mapper)).toList();
      expect(result, ['John: 30']);
    });
  });

  group('MappedCsvRowDecoder more tests', () {
    test('parses csv with escaped quotes and newlines across chunks', () async {
      final stream = Stream.fromIterable(['a,"b\n', 'c",d\n']);

      String? mapper(List<String> row) => row.join('|');

      final result =
          await stream.transform(MappedCsvRowDecoder(mapper)).toList();
      expect(result, ['a|b\nc|d']);
    });

    test('escaped quotes at the edge of chunk', () async {
      final stream = Stream.fromIterable(['a,"b"', '""', '"c",d\n']);

      String? mapper(List<String> row) => row.join('|');

      final result =
          await stream.transform(MappedCsvRowDecoder(mapper)).toList();
      expect(result, ['a|b""c|d']);
    });

    test('empty cells', () async {
      final stream = Stream.fromIterable(['a,,c\n', ',b,\n', 'x,,']);

      String? mapper(List<String> row) => row.join('|');

      final result =
          await stream.transform(MappedCsvRowDecoder(mapper)).toList();
      expect(result, ['a||c', '|b|', 'x||']);
    });

    test('double quotes at end of chunk', () async {
      final stream = Stream.fromIterable(['a,"b', '"', 'c",d\n']);

      String? mapper(List<String> row) => row.join('|');

      final result =
          await stream.transform(MappedCsvRowDecoder(mapper)).toList();
      expect(result, ['a|b|c"|d']);
    });
  });
}
