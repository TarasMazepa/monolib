import 'package:monolib_dart/csv.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'dart:async';

void main() {
  group('rfc4180 parity tests', () {
    final csvCodec = CsvCodec();
    const csvRowDecoder = CsvRowDecoder();

    Future<void> testDecode(String input, List<List<String>> expected) async {
      // Test synchronous CsvDecoder
      expect(csvCodec.decode(input), expected, reason: 'CsvDecoder failed');

      // Test asynchronous CsvRowDecoder (single chunk)
      final streamResult1 =
          await Stream.value(input).transform(csvRowDecoder).toList();
      expect(streamResult1, expected,
          reason: 'CsvRowDecoder (single chunk) failed');

      // Test asynchronous CsvRowDecoder (char by char chunks)
      final charChunks = input.split('');
      final streamResult2 = await Stream.fromIterable(charChunks)
          .transform(csvRowDecoder)
          .toList();
      expect(streamResult2, expected,
          reason: 'CsvRowDecoder (char chunks) failed');
    }

    test('aaa,bbb,ccc\r\nzzz,yyy,xxx\r\n', () async {
      await testDecode('aaa,bbb,ccc\r\nzzz,yyy,xxx\r\n', [
        ['aaa', 'bbb', 'ccc'],
        ['zzz', 'yyy', 'xxx'],
      ]);
    });
    test('aaa,bbb,ccc\r\nzzz,yyy,xxx', () async {
      await testDecode('aaa,bbb,ccc\r\nzzz,yyy,xxx', [
        ['aaa', 'bbb', 'ccc'],
        ['zzz', 'yyy', 'xxx'],
      ]);
    });
    test('"aaa","bbb","ccc"\r\nzzz,yyy,xxx', () async {
      await testDecode('"aaa","bbb","ccc"\r\nzzz,yyy,xxx', [
        ['aaa', 'bbb', 'ccc'],
        ['zzz', 'yyy', 'xxx'],
      ]);
    });
    test(
      '"aaa","b\r\nbb","ccc"\r\nzzz,yyy,xxx\r\n"aaa","b\r\nbb","ccc"\r\nzzz,yyy,xxx\r\n',
      () async {
        await testDecode(
          '"aaa","b\r\nbb","ccc"\r\nzzz,yyy,xxx\r\n"aaa","b\r\nbb","ccc"\r\nzzz,yyy,xxx\r\n',
          [
            ['aaa', 'b\r\nbb', 'ccc'],
            ['zzz', 'yyy', 'xxx'],
            ['aaa', 'b\r\nbb', 'ccc'],
            ['zzz', 'yyy', 'xxx'],
          ],
        );
      },
    );
    test('aaa,bbb,ccc\nzzz,yyy,xxx\n', () async {
      await testDecode('aaa,bbb,ccc\nzzz,yyy,xxx\n', [
        ['aaa', 'bbb', 'ccc'],
        ['zzz', 'yyy', 'xxx'],
      ]);
    });
    test('aaa,bbb,ccc\nzzz,yyy,xxx', () async {
      await testDecode('aaa,bbb,ccc\nzzz,yyy,xxx', [
        ['aaa', 'bbb', 'ccc'],
        ['zzz', 'yyy', 'xxx'],
      ]);
    });
    test('"aaa","bbb","ccc"\nzzz,yyy,xxx', () async {
      await testDecode('"aaa","bbb","ccc"\nzzz,yyy,xxx', [
        ['aaa', 'bbb', 'ccc'],
        ['zzz', 'yyy', 'xxx'],
      ]);
    });
    test(
      '"aaa","b\nbb","ccc"\nzzz,yyy,xxx\n"aaa","b\nbb","ccc"\nzzz,yyy,xxx\n',
      () async {
        await testDecode(
          '"aaa","b\nbb","ccc"\nzzz,yyy,xxx\n"aaa","b\nbb","ccc"\nzzz,yyy,xxx\n',
          [
            ['aaa', 'b\nbb', 'ccc'],
            ['zzz', 'yyy', 'xxx'],
            ['aaa', 'b\nbb', 'ccc'],
            ['zzz', 'yyy', 'xxx'],
          ],
        );
      },
    );
    test('"aaa","b""bb","ccc"', () async {
      await testDecode('"aaa","b""bb","ccc"', [
        ['aaa', 'b"bb', 'ccc'],
      ]);
    });
    test('encode test', () {
      expect(
        csvCodec.encode([
          ['"aaa', 'b"bb', 'c,cc', 'd\r\ndd'],
        ]),
        '"""aaa",b"bb,"c,cc","d\r\ndd"\r\n',
      );
    });
  });
}
