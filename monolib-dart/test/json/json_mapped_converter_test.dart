import 'dart:convert';

import 'package:monolib_dart/csv.dart';
import 'package:monolib_dart/fluent_json.dart';
import 'package:test/test.dart';

void main() {
  group('JsonMappedConverter', () {
    test('convert extracts fields from decoded JSON map', () {
      final converter = JsonMappedConverter<String>(
        (json) => json['user']['name'].unbox<String>(),
      );

      final result = converter.convert({
        'user': {'name': 'Alice'},
      });

      expect(result, 'Alice');
    });

    test('convert extracts fields from decoded JSON list', () {
      final converter = JsonMappedConverter<int>(
        (json) => json[1].unbox<int>(),
      );

      final result = converter.convert([10, 20, 30]);

      expect(result, 20);
    });

    test('convert accepts existing FluentJson instances', () {
      final converter = JsonMappedConverter<String>(
        (json) => json['title'].unbox<String>(),
      );

      final fluent = FluentJson.root({'title': 'Hello'});
      final result = converter.convert(fluent);

      expect(result, 'Hello');
    });

    test('startChunkedConversion transforms stream of decoded JSON items',
        () async {
      final stream = Stream<dynamic>.fromIterable([
        {
          'item': {'id': 1},
        },
        {
          'item': {'id': 2},
        },
      ]);

      final converter = JsonMappedConverter<int>(
        (json) => json['item']['id'].unbox<int>(),
      );

      final result = await stream.transform(converter).toList();

      expect(result, [1, 2]);
    });

    test('fuses with json.decoder to parse JSON string stream', () async {
      final stream = Stream.fromIterable([
        '{"choices":[{"message":{"content":"chunk1"}}]}',
      ]);

      final pipeline = json.decoder.fuse(
        JsonMappedConverter<String>(
          (json) => json['choices'][0]['message'].unboxed<String>('content'),
        ),
      );

      final result = await stream.transform(pipeline).toList();

      expect(result, ['chunk1']);
    });

    test('fuses with json.decoder and downstream CsvMappedDecoder', () async {
      final stream = Stream.fromIterable([
        '{"payload":"1,Alice\\n2,Bob\\n"}',
      ]);

      final pipeline = json.decoder
          .fuse(
            JsonMappedConverter<String>(
              (json) => json['payload'].unbox<String>(),
            ),
          )
          .fuse(
            CsvMappedDecoder<String>((row) => '${row[0]}:${row[1]}'),
          );

      final result = await stream.transform(pipeline).toList();

      expect(result, ['1:Alice', '2:Bob']);
    });

    test('fuses with json.decoder and downstream CsvMappedBatchDecoder',
        () async {
      final stream = Stream.fromIterable([
        '{"csv":"1,Alice\\n2,Bob\\n"}',
      ]);

      final pipeline = json.decoder
          .fuse(
            JsonMappedConverter<String>(
              (json) => json['csv'].unbox<String>(),
            ),
          )
          .fuse(
            CsvMappedBatchDecoder<String>((row) => '${row[0]}:${row[1]}'),
          );

      final result = await stream.transform(pipeline).toList();

      expect(result, [
        ['1:Alice', '2:Bob'],
      ]);
    });

    test('invokes onDone callback when stream completes', () async {
      bool doneCalled = false;
      final stream = Stream<dynamic>.fromIterable([
        {'val': 42},
      ]);

      final converter = JsonMappedConverter<int>(
        (json) => json['val'].unbox<int>(),
        onDone: () => doneCalled = true,
      );

      final result = await stream.transform(converter).toList();

      expect(result, [42]);
      expect(doneCalled, isTrue);
    });

    test('propagates selector exceptions as stream errors', () async {
      final stream = Stream<dynamic>.fromIterable([
        {'invalid': true},
      ]);

      final converter = JsonMappedConverter<String>(
        (json) => json['missing'].unbox<String>(),
      );

      expect(
        stream.transform(converter).toList(),
        throwsA(isA<Exception>()),
      );
    });
  });
}
