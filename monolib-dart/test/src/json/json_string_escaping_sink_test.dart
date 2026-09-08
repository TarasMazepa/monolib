import 'package:monolib_dart/json_encode_async.dart';
import 'package:test/test.dart';

void main() {
  group('JsonStringEscapingSink', () {
    late StringBuffer buffer;
    late JsonStringEscapingSink sink;

    setUp(() {
      buffer = StringBuffer();
      sink = JsonStringEscapingSink(buffer);
    });

    test(
      'writes standard strings unescaped (except for json string rules)',
      () {
        sink.write('hello world');
        expect(buffer.toString(), 'hello world');
      },
    );

    test('writes empty or null strings as nothing', () {
      sink.write('');
      expect(buffer.toString(), '');

      sink.write(null);
      expect(buffer.toString(), '');
    });

    test('escapes newlines correctly', () {
      sink.write('hello\nworld');
      expect(buffer.toString(), r'hello\nworld');
    });

    test('escapes quotes correctly', () {
      sink.write('hello "world"');
      expect(buffer.toString(), r'hello \"world\"');
    });

    test('escapes backslashes correctly', () {
      sink.write(r'hello \ world');
      expect(buffer.toString(), r'hello \\ world');
    });

    test('escapes unicode characters properly', () {
      // Dart's jsonEncode might not escape unicode by default, but tests string behavior
      sink.write('hello 😊');
      expect(buffer.toString(), 'hello 😊');
    });

    test('writeln writes the string and an escaped newline', () {
      sink.writeln('hello');
      // write('hello') -> 'hello'
      // write('\n') -> '\n'
      expect(buffer.toString(), r'hello\n');
    });

    test('writeln with no arguments writes just an escaped newline', () {
      sink.writeln();
      // write('') -> ''
      // write('\n') -> '\n'
      expect(buffer.toString(), r'\n');
    });

    test('writeAll writes all items with empty separator', () {
      sink.writeAll(['a', 'b\n', 'c']);
      expect(buffer.toString(), r'ab\nc');
    });

    test('writeAll writes all items with an escaped separator', () {
      sink.writeAll(['a', 'b', 'c'], '\n');
      expect(buffer.toString(), r'a\nb\nc');
    });

    test('writeCharCode writes an escaped character', () {
      // 10 is \n
      sink.writeCharCode(10);
      expect(buffer.toString(), r'\n');

      // 34 is "
      buffer.clear();
      sink.writeCharCode(34);
      expect(buffer.toString(), r'\"');
    });
  });
}
