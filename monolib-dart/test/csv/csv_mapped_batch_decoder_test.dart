import 'dart:async';

import 'package:monolib_dart/src/csv/csv_mapped_batch_decoder.dart';
import 'package:test/test.dart';

void main() {
  group('CsvMappedBatchDecoder', () {
    test('parses simple csv across chunks and batches them', () async {
      final stream = Stream.fromIterable(['name,age\n', 'John,30\n']);

      String? mapper(List<String> row) {
        if (row.length == 2) {
          return '${row[0]}: ${row[1]}';
        }
        return null;
      }

      final result = await stream
          .transform(CsvMappedBatchDecoder(mapper))
          .toList();
      expect(result, [
        ['name: age'],
        ['John: 30'],
      ]);
    });

    test('filters rows when mapper returns null', () async {
      final stream = Stream.fromIterable([
        'name,age\nJohn,30\n',
        'Jane,notanumber\n',
      ]);

      String? mapper(List<String> row) {
        if (row[0] == 'name') return null; // filter header
        if (int.tryParse(row[1]) == null) return null; // filter invalid age
        return '${row[0]}: ${row[1]}';
      }

      final result = await stream
          .transform(CsvMappedBatchDecoder(mapper))
          .toList();
      expect(result, [
        ['John: 30'],
      ]);
    });

    test(
      'exhaustively tests all chunk boundaries by feeding 1 char at a time',
      () async {
        final csvData =
            'a,"b""\nc",d\n"e,f",g\n\r\n"h\r\ni",j"k"\r\nlast,,\n"aaa","b""bb","ccc"';

        String? mapper(List<String> row) => row.join('|');

        // Test baseline with a single large chunk
        final baselineStream = Stream.fromIterable([csvData]);
        final baselineResult = await baselineStream
            .transform(CsvMappedBatchDecoder(mapper))
            .expand((e) => e)
            .toList();

        // Test with 1-character chunks
        final charStream = Stream.fromIterable(csvData.split(''));
        final charResult = await charStream
            .transform(CsvMappedBatchDecoder(mapper))
            .expand((e) => e)
            .toList();

        expect(
          charResult,
          equals(baselineResult),
          reason: '1-char chunks should match baseline when flattened',
        );
      },
    );
  });
}
