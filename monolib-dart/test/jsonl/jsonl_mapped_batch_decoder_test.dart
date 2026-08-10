import 'dart:async';

import 'package:monolib_dart/src/jsonl/jsonl_mapped_batch_decoder.dart';
import 'package:test/test.dart';

void main() {
  group('JsonlMappedBatchDecoder', () {
    test('parses jsonl across chunks and batches them', () async {
      final stream = Stream.fromIterable([
        '{"name": "John"}\n{"name": "Ja',
        'ne"}\n{"name": "Bob"}',
      ]);

      String? mapper(dynamic json) {
        return json['name'] as String?;
      }

      final result =
          await stream.transform(JsonlMappedBatchDecoder(mapper)).toList();

      expect(result, [
        ['John'],
        ['Jane'],
        ['Bob'],
      ]);
    });

    test('filters rows when mapper returns null', () async {
      final stream = Stream.fromIterable([
        '{"name": "John"}\n{"skip": true}\n{"name": "Bob"}',
      ]);

      String? mapper(dynamic json) {
        if (json['skip'] == true) return null;
        return json['name'] as String?;
      }

      final result =
          await stream.transform(JsonlMappedBatchDecoder(mapper)).toList();

      expect(result, [
        ['John'],
        ['Bob'],
      ]);
    });

    test(
      'exhaustively tests all chunk boundaries by feeding 1 char at a time',
      () async {
        final jsonlData = '{"name": "John"}\n{"name": "Jane"}\n{"name": "Bob"}';

        String? mapper(dynamic json) => json['name'] as String?;

        // Test baseline with a single large chunk
        final baselineStream = Stream.fromIterable([jsonlData]);
        final baselineResult = await baselineStream
            .transform(JsonlMappedBatchDecoder(mapper))
            .expand((e) => e)
            .toList();

        // Test with 1-character chunks
        final charStream = Stream.fromIterable(jsonlData.split(''));
        final charResult = await charStream
            .transform(JsonlMappedBatchDecoder(mapper))
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
