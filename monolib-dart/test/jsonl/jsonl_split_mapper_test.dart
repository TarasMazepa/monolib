import 'dart:async';
import 'dart:convert';

import 'package:monolib_dart/jsonl.dart';
import 'package:test/test.dart';

void main() {
  group('JsonlSplitMapper', () {
    test('convert() throws UnsupportedError', () {
      const mapper = JsonlSplitMapper<Map<String, dynamic>>(_castMap);
      expect(
        () => mapper.convert('{"a":1}'),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('parses basic JSONL stream', () async {
      final stream = Stream.fromIterable([
        '{"id":1,"name":"Alice"}\n{"id":2,"name":"Bob"}\n',
      ]);

      final result = await stream
          .transform(
            const JsonlSplitMapper<Map<String, dynamic>>(_castMap),
          )
          .toList();

      expect(result, [
        {'id': 1, 'name': 'Alice'},
        {'id': 2, 'name': 'Bob'},
      ]);
    });

    test('handles lines split across multiple arbitrary chunks', () async {
      final stream = Stream.fromIterable([
        '{"id":',
        '1,"na',
        'me":"Alice"}\n{"id":2,',
        '"name":"Bob"}\n',
      ]);

      final result = await stream
          .transform(
            const JsonlSplitMapper<Map<String, dynamic>>(_castMap),
          )
          .toList();

      expect(result, [
        {'id': 1, 'name': 'Alice'},
        {'id': 2, 'name': 'Bob'},
      ]);
    });

    test('supports CRLF newlines', () async {
      final stream = Stream.fromIterable([
        '{"id":1}\r\n{"id":2}\r\n',
      ]);

      final result = await stream
          .transform(
            const JsonlSplitMapper<Map<String, dynamic>>(_castMap),
          )
          .toList();

      expect(result, [
        {'id': 1},
        {'id': 2},
      ]);
    });

    test('processes leftover carry when stream closes without trailing newline',
        () async {
      final stream = Stream.fromIterable([
        '{"id":1}\n{"id":2}',
      ]);

      final result = await stream
          .transform(
            const JsonlSplitMapper<Map<String, dynamic>>(_castMap),
          )
          .toList();

      expect(result, [
        {'id': 1},
        {'id': 2},
      ]);
    });

    test('skips empty lines and multiple consecutive newlines', () async {
      final stream = Stream.fromIterable([
        '\n\n{"id":1}\n\n\r\n{"id":2}\n\n',
      ]);

      final result = await stream
          .transform(
            const JsonlSplitMapper<Map<String, dynamic>>(_castMap),
          )
          .toList();

      expect(result, [
        {'id': 1},
        {'id': 2},
      ]);
    });

    test('filters out nulls returned by mapper', () async {
      final stream = Stream.fromIterable([
        '{"id":1,"active":true}\n{"id":2,"active":false}\n{"id":3,"active":true}\n',
      ]);

      int? activeIdMapper(dynamic json) {
        if (json is Map && json['active'] == true) {
          return json['id'] as int?;
        }
        return null;
      }

      final result = await stream
          .transform(JsonlSplitMapper<int>(activeIdMapper))
          .toList();

      expect(result, [1, 3]);
    });

    test('rethrows malformed JSON by default (ignoreExceptions = false)', () {
      final stream = Stream.fromIterable([
        '{"id":1}\n{invalid json}\n{"id":2}\n',
      ]);

      expect(
        () => stream
            .transform(
              const JsonlSplitMapper<Map<String, dynamic>>(_castMap),
            )
            .toList(),
        throwsA(isA<FormatException>()),
      );
    });

    test('skips malformed JSON when ignoreExceptions is true', () async {
      final stream = Stream.fromIterable([
        '{"id":1}\n{invalid json}\n{"id":2}\n',
      ]);

      final result = await stream
          .transform(
            const JsonlSplitMapper<Map<String, dynamic>>(
              _castMap,
              ignoreExceptions: true,
            ),
          )
          .toList();

      expect(result, [
        {'id': 1},
        {'id': 2},
      ]);
    });

    test('fuses with utf8.decoder on byte streams', () async {
      final input = utf8.encode('{"val":"test1"}\n{"val":"test2"}\n');
      final stream = Stream<List<int>>.fromIterable(
          [input.sublist(0, 10), input.sublist(10)]);

      final result = await stream
          .transform(utf8.decoder)
          .transform(
            const JsonlSplitMapper<Map<String, dynamic>>(_castMap),
          )
          .toList();

      expect(result, [
        {'val': 'test1'},
        {'val': 'test2'},
      ]);
    });
  });
}

Map<String, dynamic>? _castMap(dynamic json) {
  if (json is Map) {
    return json.cast<String, dynamic>();
  }
  return null;
}
