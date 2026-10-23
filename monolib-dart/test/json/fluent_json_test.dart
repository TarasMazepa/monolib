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

    test('unbox converts num to double when T is double', () {
      final json = FluentJson.root({'score': 0, 'fractional': 12.34});
      expect(json['score'].unbox<double>(), 0.0);
      expect(json['fractional'].unbox<double>(), 12.34);
      expect(json.unboxed<double>('score'), 0.0);
      expect(json.unboxed<double>('fractional'), 12.34);
      expect(json.unboxedElementAt<double>('score'), 0.0);
    });

    test('unbox converts num to double when T is double?', () {
      final json = FluentJson.root({'score': 42, 'missing': null});
      expect(json['score'].unbox<double?>(), 42.0);
      expect(FluentJson.root(null).unbox<double?>(), isNull);
      expect(json.unboxed<double?>('score'), 42.0);
      expect(json.unboxed<double?>('missing'), isNull);
      expect(json.unboxedElementAt<double?>('score'), 42.0);
      expect(json.unboxedElementAt<double?>('missing'), isNull);
    });
  });
}
