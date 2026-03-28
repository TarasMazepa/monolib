import 'package:monolib_dart/jsonl.dart';
import 'package:test/test.dart';

void main() {
  group('JsonlCodec', () {
    const jsonl = JsonlCodec();

    test('encoder', () {
      final input = [
        {"id": 1, "name": "test"},
        [1, 2, 3],
        "hello",
      ];
      final encoded = jsonl.encode(input);
      expect(encoded, '{"id":1,"name":"test"}\n[1,2,3]\n"hello"\n');
    });

    test('decoder', () {
      final input = '{"id":1,"name":"test"}\n[1,2,3]\n"hello"\n';
      final decoded = jsonl.decode(input);
      expect(decoded, [
        {"id": 1, "name": "test"},
        [1, 2, 3],
        "hello",
      ]);
    });

    test('decoder with empty string', () {
      final input = '';
      final decoded = jsonl.decode(input);
      expect(decoded, []);
    });

    test('decoder with missing trailing newline', () {
      final input = '{"id":1}\n{"id":2}';
      final decoded = jsonl.decode(input);
      expect(decoded, [
        {"id": 1},
        {"id": 2}
      ]);
    });

    test('decoder with multiple newlines and empty strings', () {
      final input = '\n{"id":1}\n\n[1]\n\n';
      final decoded = jsonl.decode(input);
      expect(decoded, [
        {"id": 1},
        [1],
      ]);
    });
  });
}
