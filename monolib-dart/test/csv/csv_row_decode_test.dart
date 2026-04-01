import 'package:monolib_dart/csv.dart';
import 'package:test/test.dart';

void main() {
  test('csvRowDecode', () {
    expect(csvRowDecode('a,b,c'), ['a', 'b', 'c']);
    expect(csvRowDecode('"a,b",c'), ['a,b', 'c']);
    expect(csvRowDecode(''), []);
    expect(csvRowDecode('""'), ['']);
    expect(csvRowDecode('"a""b"'), ['a"b']);
  });
}
