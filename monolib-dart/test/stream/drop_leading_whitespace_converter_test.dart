import 'dart:convert';

import 'package:monolib_dart/stream.dart';
import 'package:test/test.dart';

void main() {
  group('DropLeadingWhitespaceConverter', () {
    test('convert drops leading whitespace', () {
      final result = const DropLeadingWhitespaceConverter().convert(
        utf8.encode(' \n\r\t{"a": 1}'),
      );

      expect(utf8.decode(result), equals('{"a": 1}'));
    });

    test('convert returns empty list for whitespace only input', () {
      final result = const DropLeadingWhitespaceConverter().convert(
        utf8.encode(' \n\r\t'),
      );

      expect(result, isEmpty);
    });

    test('convert keeps input without leading whitespace', () {
      final result = const DropLeadingWhitespaceConverter().convert(
        utf8.encode('{"a": 1}'),
      );

      expect(utf8.decode(result), equals('{"a": 1}'));
    });

    test('chunked conversion drops whitespace spread across chunks', () async {
      final result = await Stream<List<int>>.fromIterable([
        utf8.encode('  '),
        utf8.encode('\n\n'),
        utf8.encode('\t {"a"'),
        utf8.encode(': 1}'),
      ]).transform(const DropLeadingWhitespaceConverter()).toList();

      expect(utf8.decode(result.expand((e) => e).toList()), '{"a": 1}');
    });

    test('chunked conversion keeps whitespace after content', () async {
      final result = await Stream<List<int>>.fromIterable([
        utf8.encode(' {"a":'),
        utf8.encode('  \n'),
        utf8.encode(' 1} '),
      ]).transform(const DropLeadingWhitespaceConverter()).toList();

      expect(utf8.decode(result.expand((e) => e).toList()), '{"a":  \n 1} ');
    });

    test('chunked conversion emits nothing for whitespace only stream',
        () async {
      final result = await Stream<List<int>>.fromIterable([
        utf8.encode('  '),
        utf8.encode('\r\n'),
      ]).transform(const DropLeadingWhitespaceConverter()).toList();

      expect(result, isEmpty);
    });

    test('fuses with utf8 and json decoders', () async {
      final result = await Stream<List<int>>.fromIterable([
        utf8.encode('\n\n  '),
        utf8.encode('{"a": [1, 2]}'),
      ])
          .transform(
            const DropLeadingWhitespaceConverter()
                .fuse(utf8.decoder)
                .fuse(json.decoder),
          )
          .toList();

      expect(
        result,
        equals([
          {
            'a': [1, 2],
          },
        ]),
      );
    });
  });
}
