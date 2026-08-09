import 'dart:async';

import 'package:monolib_dart/src/jsonl/jsonl_chunked_decoder.dart';
import 'package:test/test.dart';

void main() {
  group('JsonlChunkedDecoder', () {
    test('parses jsonl across chunks', () async {
      final stream = Stream.fromIterable([
        '{"id":1}\n',
        '{"id":2',
        '}\n{"id":3}',
      ]);
      final result =
          await stream.transform(const JsonlChunkedDecoder()).toList();
      expect(result, [
        {"id": 1},
        {"id": 2},
        {"id": 3},
      ]);
    });

    test('ignores empty lines and carriage returns', () async {
      final stream = Stream.fromIterable([
        '\r\n{"id":1}\r\n',
        '\r\n\r\n{"id":2}\n',
      ]);
      final result =
          await stream.transform(const JsonlChunkedDecoder()).toList();
      expect(result, [
        {"id": 1},
        {"id": 2},
      ]);
    });

    test('exhaustively tests all chunk boundaries by feeding 1 char at a time',
        () async {
      final jsonlData =
          '{"id":1}\r\n{"name":"test"}\n[1,2,3]\r\n\r\n"hello"\n{"last":true}';

      // Test baseline with a single large chunk
      final baselineStream = Stream.fromIterable([jsonlData]);
      final baselineResult =
          await baselineStream.transform(const JsonlChunkedDecoder()).toList();

      // Test with 1-character chunks
      final charStream = Stream.fromIterable(jsonlData.split(''));
      final charResult =
          await charStream.transform(const JsonlChunkedDecoder()).toList();

      // Test with 2-character chunks
      final List<String> chunksOf2 = [];
      for (int i = 0; i < jsonlData.length; i += 2) {
        chunksOf2.add(jsonlData.substring(
            i, i + 2 > jsonlData.length ? jsonlData.length : i + 2));
      }
      final twoCharStream = Stream.fromIterable(chunksOf2);
      final twoCharResult =
          await twoCharStream.transform(const JsonlChunkedDecoder()).toList();

      expect(charResult, equals(baselineResult),
          reason: '1-char chunks should match baseline');
      expect(twoCharResult, equals(baselineResult),
          reason: '2-char chunks should match baseline');
    });
  });
}
