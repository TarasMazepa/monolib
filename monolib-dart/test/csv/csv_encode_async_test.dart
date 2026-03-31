import 'dart:async';

import 'package:monolib_dart/csv.dart';
import 'package:test/test.dart';

void main() {
  group('csvEncodeAsync', () {
    test('encodes Iterable correctly', () async {
      final items = [
        ['a', 'b', 'c'],
        ['1', '2', '3'],
        ['"quoted"', 'newline\n', 'comma,'],
      ];
      final buffer = StringBuffer();
      await csvEncodeAsync(items, buffer);
      expect(
        buffer.toString(),
        'a,b,c\r\n1,2,3\r\n"""quoted""","newline\n","comma,"\r\n',
      );
    });

    test('encodes Stream correctly', () async {
      final items = Stream.fromIterable([
        ['a', 'b', 'c'],
        ['1', '2', '3'],
        ['"quoted"', 'newline\n', 'comma,'],
      ]);
      final buffer = StringBuffer();
      await csvEncodeAsync(items, buffer);
      expect(
        buffer.toString(),
        'a,b,c\r\n1,2,3\r\n"""quoted""","newline\n","comma,"\r\n',
      );
    });

    test('handles futures in iterables and cells', () async {
      final items = [
        Future.value(['a', 'b', Future.value('c')]),
        ['1', '2', '3'],
      ];
      final buffer = StringBuffer();
      await csvEncodeAsync(items, buffer);
      expect(buffer.toString(), 'a,b,c\r\n1,2,3\r\n');
    });

    test('throws ArgumentError for invalid input', () async {
      final buffer = StringBuffer();
      expect(() => csvEncodeAsync('invalid', buffer), throwsArgumentError);
    });
  });
}
