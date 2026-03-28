import 'package:monolib_dart/csv.dart';
import 'package:monolib_dart/monolib_dart.dart';
import 'package:test/test.dart';

class _CustomObj {
  List<String> toCsv() => ['a', 'b', 'c'];
}

void main() {
  group('csv codec', () {
    test('encode simple list', () {
      final input = [
        ['1', '2', '3'],
        ['a', 'b', 'c']
      ];
      final output = csv.encode(input);
      expect(output, '1,2,3\r\na,b,c\r\n');
    });

    test('encode with strings needing escape', () {
      final input = [
        ['1', '2,2', '3\r\n3'],
        ['"a"', 'b\rc', 'c']
      ];
      final output = csv.encode(input);
      expect(output, '1,"2,2","3\r\n3"\r\n"""a""",b\rc,c\r\n');
    });

    test('encode custom object', () {
      final input = [
        _CustomObj()
      ];
      final output = csv.encode(input);
      expect(output, 'a,b,c\r\n');
    });

    test('decode simple list', () {
      final input = '1,2,3\r\na,b,c\r\n';
      final output = csv.decode(input);
      expect(output, [
        ['1', '2', '3'],
        ['a', 'b', 'c']
      ]);
    });

    test('decode with strings needing escape', () {
      final input = '1,"2,2","3\r\n3"\r\n"""a""",b\rc,c\r\n';
      final output = csv.decode(input);
      expect(output, [
        ['1', '2,2', '3\r\n3'],
        ['"a"', 'b\rc', 'c']
      ]);
    });
  });

  group('csv extensions', () {
    test('isTrimmedDeepEqualsTo', () {
      expect([' a ', 'b'].isTrimmedDeepEqualsTo(['a', 'b']), isTrue);
      expect([' a ', 'b'].isTrimmedDeepEqualsTo(['a', 'c']), isFalse);
    });

    test('skipFirstIfIsCsvHeaderRow', () {
      final input = [
        ['name', 'age'],
        ['john', '20']
      ];

      final res1 = input.skipFirstIfIsCsvHeaderRow(
        isCsvHeaderRow: (row) => row.isTrimmedDeepEqualsTo(['name', 'age'])
      ).toList();
      expect(res1, [['john', '20']]);

      final res2 = input.skipFirstIfIsCsvHeaderRow(
        isCsvHeaderRow: (row) => row.isTrimmedDeepEqualsTo(['wrong', 'header'])
      ).toList();
      expect(res2, [
        ['name', 'age'],
        ['john', '20']
      ]);
    });

    test('decodeCsv on String', () {
      final input = '1,2,3\r\na,b,c\r\n';
      expect(input.decodeCsv(), [
        ['1', '2', '3'],
        ['a', 'b', 'c']
      ]);
    });
  });
}
