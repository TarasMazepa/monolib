import 'dart:async';
import 'dart:convert';

import 'package:monolib_dart/stream.dart';
import 'package:test/test.dart';

void main() {
  group('LineSplitterBatchConverter', () {
    test('convert() throws UnsupportedError', () {
      const converter = LineSplitterBatchConverter<String>();
      expect(
        () => converter.convert('a\nb\n'),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('splits lines and batches them per chunk', () async {
      final stream = Stream.fromIterable([
        'line1\nline2\n',
        'line3\n',
      ]);

      final result = await stream
          .transform(const LineSplitterBatchConverter<String>())
          .toList();

      expect(result, [
        ['line1', 'line2'],
        ['line3'],
      ]);
    });

    test('handles lines split across chunk boundaries', () async {
      final stream = Stream.fromIterable([
        'hello ',
        'world\npart',
        ' 1\npart 2',
      ]);

      final result = await stream
          .transform(const LineSplitterBatchConverter<String>())
          .toList();

      expect(result, [
        ['hello world'],
        ['part 1'],
        ['part 2'],
      ]);
    });

    test('preserves empty lines', () async {
      final stream = Stream.fromIterable(['line1\n\nline2\n']);

      final result = await stream
          .transform(const LineSplitterBatchConverter<String>())
          .toList();

      expect(result, [
        ['line1', '', 'line2'],
      ]);
    });

    test('handles CRLF and CR newlines across chunks', () async {
      final stream = Stream.fromIterable([
        'line1\r\nline2\r',
        '\nline3\rline4\n',
      ]);

      final result = await stream
          .transform(const LineSplitterBatchConverter<String>())
          .toList();

      expect(result, [
        ['line1', 'line2'],
        ['line3', 'line4'],
      ]);
    });

    test('maps lines and filters out null results', () async {
      final stream = Stream.fromIterable([
        '10\n# comment\n20\n',
        '# another comment\n30\n',
      ]);

      int? mapper(String line) {
        if (line.startsWith('#')) return null;
        return int.tryParse(line);
      }

      final result = await stream
          .transform(
            LineSplitterBatchConverter<int>.mapped(mapper),
          )
          .toList();

      expect(result, [
        [10, 20],
        [30],
      ]);
    });

    test('does not emit a batch when all lines in chunk map to null', () async {
      final stream = Stream.fromIterable([
        '# skip this whole chunk\n# second comment\n',
        'hello\n',
      ]);

      String? mapper(String line) => line.startsWith('#') ? null : line;

      final result = await stream
          .transform(
            LineSplitterBatchConverter<String>(mapper: mapper),
          )
          .toList();

      expect(result, [
        ['hello'],
      ]);
    });

    test('handles empty stream', () async {
      final stream = Stream<String>.empty();
      final result = await stream
          .transform(const LineSplitterBatchConverter<String>())
          .toList();
      expect(result, isEmpty);
    });

    test('invokes onBatch before emitting each batch', () async {
      final batchesRecorded = <List<String>>[];
      final stream = Stream.fromIterable([
        'a\nb\n',
        'c\n',
      ]);

      final result = await stream
          .transform(
            LineSplitterBatchConverter<String>(
              onBatch: (batch) => batchesRecorded.add(List.from(batch)),
            ),
          )
          .toList();

      expect(result, [
        ['a', 'b'],
        ['c'],
      ]);
      expect(batchesRecorded, [
        ['a', 'b'],
        ['c'],
      ]);
    });

    test('invokes onDone when stream completes', () async {
      bool onDoneCalled = false;
      final decoder = LineSplitterBatchConverter<String>(
        onDone: () => onDoneCalled = true,
      );

      final controller = StreamController<List<String>>();
      final sink = decoder.startChunkedConversion(controller);

      sink.add('hello\n');
      expect(onDoneCalled, isFalse);

      sink.close();
      expect(onDoneCalled, isTrue);
    });

    test(
      'exhaustively tests all chunk boundaries by feeding 1 char at a time',
      () async {
        final textData = 'line 1\r\nline 2\n\nline 3\rline 4\nlast line';

        final baselineStream = Stream.fromIterable([textData]);
        final baselineResult = await baselineStream
            .transform(const LineSplitterBatchConverter<String>())
            .expand((b) => b)
            .toList();

        final charStream = Stream.fromIterable(textData.split(''));
        final charResult = await charStream
            .transform(const LineSplitterBatchConverter<String>())
            .expand((b) => b)
            .toList();

        expect(
          charResult,
          equals(baselineResult),
          reason: '1-char chunks should match baseline when flattened',
        );
      },
    );

    test('can be fused with utf8.decoder', () async {
      final pipeline =
          utf8.decoder.fuse(const LineSplitterBatchConverter<String>());

      final byteStream = Stream<List<int>>.fromIterable([
        utf8.encode('chunk1 line1\nchunk1 line2\n'),
        utf8.encode('chunk2 line1\n'),
      ]);

      final result = await byteStream.transform(pipeline).toList();

      expect(result, [
        ['chunk1 line1', 'chunk1 line2'],
        ['chunk2 line1'],
      ]);
    });

    test(
        'works via typedefs LineSplitterBatchDecoder and LineSplitterMappedBatchDecoder',
        () async {
      final stream1 = Stream.fromIterable(['a\nb\n']);
      final result1 = await stream1
          .transform(const LineSplitterBatchDecoder<String>())
          .toList();
      expect(result1, [
        ['a', 'b'],
      ]);

      final stream2 = Stream.fromIterable(['1\n2\n']);
      final result2 = await stream2
          .transform(LineSplitterMappedBatchDecoder<int>.mapped(int.parse))
          .toList();
      expect(result2, [
        [1, 2],
      ]);
    });
  });
}
