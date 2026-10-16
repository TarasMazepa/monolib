import 'package:monolib_dart/src/json/fluent_json.dart';
import 'package:test/test.dart';

void main() {
  group('FluentJson', () {
    test('operator [] throws ArgumentError on negative index', () {
      final json = FluentJson.root(['a', 'b', 'c']);
      expect(
        () => json[-1],
        throwsA(isA<ArgumentError>().having(
            (e) => e.message, 'message', 'Index must be non-negative.')),
      );
    });

    test('elementAt throws ArgumentError on negative index', () {
      final json = FluentJson.root(['a', 'b', 'c']);
      expect(
        () => json.elementAt(-1),
        throwsA(isA<ArgumentError>().having(
            (e) => e.message, 'message', 'Index must be non-negative.')),
      );
    });

    test('operator [] throws Exception with RangeError on out-of-bounds index',
        () {
      final json = FluentJson.root(['a', 'b', 'c']);
      expect(
        () => json[3],
        throwsA(isA<Exception>()
            .having((e) => e.toString(), 'toString', contains('RangeError'))),
      );
    });

    test('elementAt returns null on out-of-bounds index', () {
      final json = FluentJson.root(['a', 'b', 'c']);
      expect(json.elementAt(3), isNull);
    });
  });
}
