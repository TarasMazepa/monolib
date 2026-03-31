import 'package:monolib_dart/csv.dart';
import 'package:test/test.dart';

void main() {
  group('CsvDecoder', () {
    const decoder = CsvDecoder();

    test('decodes basic CSV synchronously', () {
      expect(
        decoder.convert('a,b,c\n1,2,3'),
        equals([
          ['a', 'b', 'c'],
          ['1', '2', '3']
        ]),
      );
    });

    test('decodes empty string synchronously', () {
      expect(
        decoder.convert(''),
        equals([]),
      );
    });

    test('decodes single value synchronously', () {
      expect(
        decoder.convert('a'),
        equals([
          ['a']
        ]),
      );
    });

    test('decodes CSV with quotes synchronously', () {
      expect(
        decoder.convert('a,"b,c",d'),
        equals([
          ['a', 'b,c', 'd']
        ]),
      );
    });

    test('decodes CSV with newlines inside quotes synchronously', () {
      expect(
        decoder.convert('a,"b\nc",d'),
        equals([
          ['a', 'b\nc', 'd']
        ]),
      );
    });

    test('decodes CSV ending with comma synchronously', () {
      expect(
        decoder.convert('a,b,'),
        equals([
          ['a', 'b', '']
        ]),
      );
    });

    group('chunked conversion', () {
      Future<List<List<String>>> decodeChunks(List<String> chunks) async {
        final stream = Stream.fromIterable(chunks);
        final result = await stream.transform(decoder).toList();
        return result.expand((element) => element).toList();
      }

      test('decodes simple chunks', () async {
        expect(
          await decodeChunks(['a,b,', 'c\n1,', '2,3']),
          equals([
            ['a', 'b', 'c'],
            ['1', '2', '3']
          ]),
        );
      });

      test('decodes chunks split in the middle of a value', () async {
        expect(
          await decodeChunks(['a,b,val', 'ue1\n1,2,3']),
          equals([
            ['a', 'b', 'value1'],
            ['1', '2', '3']
          ]),
        );
      });

      test('decodes chunks split in the middle of double quotes', () async {
        expect(
          await decodeChunks(['a,b,"val', 'ue,1"\n1,2,3']),
          equals([
            ['a', 'b', 'value,1'],
            ['1', '2', '3']
          ]),
        );
      });

      test('decodes chunks split exactly at double quotes escape', () async {
        expect(
          await decodeChunks(['a,b,"val""', '""ue"\n1,2,3']),
          equals([
            ['a', 'b', 'val""ue'],
            ['1', '2', '3']
          ]),
        );
      });

      test('decodes chunks split at newline (\\r\\n)', () async {
        expect(
          await decodeChunks(['a,b,c\r', '\n1,2,3']),
          equals([
            ['a', 'b', 'c'],
            ['1', '2', '3']
          ]),
        );
      });

      test('decodes chunks split at comma', () async {
        expect(
          await decodeChunks(['a,b', ',', 'c\n1,2,3']),
          equals([
            ['a', 'b', 'c'],
            ['1', '2', '3']
          ]),
        );
      });

      test('decodes chunks ending with comma', () async {
        expect(
          await decodeChunks(['a,b,']),
          equals([
            ['a', 'b', '']
          ]),
        );
      });

      test('decodes stream of 1 character each', () async {
        expect(
          await decodeChunks('a,"b,c",d\n1,2,3'.split('')),
          equals([
            ['a', 'b,c', 'd'],
            ['1', '2', '3']
          ]),
        );
      });
    });
  });
}
