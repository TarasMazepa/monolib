import 'dart:async';

import 'package:monolib_dart/src/csv/csv_mapped_decoder.dart';
import 'package:test/test.dart';

void main() {
  group('CsvMappedDecoder', () {
    test('parses simple csv across chunks and maps to objects', () async {
      final stream = Stream.fromIterable(['name,age\n', 'John,30\n']);

      String? mapper(List<String> row) {
        if (row.length == 2) {
          return '${row[0]}: ${row[1]}';
        }
        return null;
      }

      final result = await stream.transform(CsvMappedDecoder(mapper)).toList();
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

      final result = await stream.transform(CsvMappedDecoder(mapper)).toList();
      expect(result, ['John: 30']);
    });
  });

  group('CsvMappedDecoder more tests', () {
    test('parses csv with escaped quotes and newlines across chunks', () async {
      final stream = Stream.fromIterable(['a,"b\n', 'c",d\n']);

      String? mapper(List<String> row) => row.join('|');

      final result = await stream.transform(CsvMappedDecoder(mapper)).toList();
      expect(result, ['a|b\nc|d']);
    });

    test('escaped quotes at the edge of chunk', () async {
      final stream = Stream.fromIterable(['a,"b"', '""', '"c",d\n']);

      String? mapper(List<String> row) => row.join('|');

      final result = await stream.transform(CsvMappedDecoder(mapper)).toList();
      expect(result, ['a|b""c|d']);
    });

    test('empty cells', () async {
      final stream = Stream.fromIterable(['a,,c\n', ',b,\n', 'x,,']);

      String? mapper(List<String> row) => row.join('|');

      final result = await stream.transform(CsvMappedDecoder(mapper)).toList();
      expect(result, ['a||c', '|b|', 'x||']);
    });

    test('double quotes at end of chunk', () async {
      final stream = Stream.fromIterable(['a,"b', '"', 'c",d\n']);

      String? mapper(List<String> row) => row.join('|');

      final result = await stream.transform(CsvMappedDecoder(mapper)).toList();
      expect(result, ['a|b|c"|d']);
    });

    test('completes correctly when subscription uses asFuture', () async {
      final controller = StreamController<String>();
      final List<String> received = [];

      final sub = controller.stream
          .transform(CsvMappedDecoder((row) => row.join(',')))
          .listen(received.add);

      final future = sub.asFuture();
      controller.add('1,2\n3,4\n');
      await controller.close();
      await future;

      expect(received, ['1,2', '3,4']);
    });

    test('supports pause and resume', () async {
      final controller = StreamController<String>();
      final List<String> received = [];

      final sub = controller.stream
          .transform(CsvMappedDecoder((row) => row.join(',')))
          .listen(received.add);

      sub.pause();
      expect(sub.isPaused, isTrue);
      controller.add('1,2\n');
      expect(received, isEmpty);

      sub.resume();
      await Future<void>.delayed(Duration.zero);
      expect(received, ['1,2']);

      await controller.close();
    });

    test(
      'exhaustively tests all chunk boundaries by feeding 1 char at a time',
      () async {
        final csvData =
            'a,"b""\nc",d\n"e,f",g\n\r\n"h\r\ni",j"k"\r\nlast,,\n"aaa","b""bb","ccc"';

        String? mapper(List<String> row) => row.join('|');

        // Test baseline with a single large chunk
        final baselineStream = Stream.fromIterable([csvData]);
        final baselineResult =
            await baselineStream.transform(CsvMappedDecoder(mapper)).toList();

        // Test with 1-character chunks
        final charStream = Stream.fromIterable(csvData.split(''));
        final charResult =
            await charStream.transform(CsvMappedDecoder(mapper)).toList();

        // Test with 2-character chunks
        final List<String> chunksOf2 = [];
        for (int i = 0; i < csvData.length; i += 2) {
          chunksOf2.add(
            csvData.substring(
              i,
              i + 2 > csvData.length ? csvData.length : i + 2,
            ),
          );
        }
        final twoCharStream = Stream.fromIterable(chunksOf2);
        final twoCharResult =
            await twoCharStream.transform(CsvMappedDecoder(mapper)).toList();

        expect(
          charResult,
          equals(baselineResult),
          reason: '1-char chunks should match baseline',
        );
        expect(
          twoCharResult,
          equals(baselineResult),
          reason: '2-char chunks should match baseline',
        );
      },
    );

    test('calls onDone when stream finishes', () async {
      bool onDoneCalled = false;
      final decoder = CsvMappedDecoder<String>(
        (row) => row.join(','),
        onDone: () {
          onDoneCalled = true;
        },
      );

      final sink = decoder.startChunkedConversion(StreamController<String>());
      sink.add('a,b,c\n');

      expect(onDoneCalled, isFalse);
      sink.close();
      expect(onDoneCalled, isTrue);
    });
  });
}
