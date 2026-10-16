import 'package:monolib_dart/monolib_dart.dart';
import 'package:test/test.dart';

void main() {
  group('OnIterable', () {
    test('sum', () {
      expect([1, 2, 3].sum(), 6);
      expect([1.5, 2.5].sum(), 4.0);
      expect(<int>[].sum(), 0);
      expect(<double>[].sum(), 0.0);
      expect(<num>[].sum(), 0);
      expect(<String>[].sum(zero: ''), '');
      expect(() => <String>[].sum(), throwsStateError);
    });

    test('sumBy', () {
      expect(['a', 'bb', 'ccc'].sumBy((e) => e.length), 6);
      expect(<String>[].sumBy<int>((e) => e.length), 0);
      expect(<String>[].sumBy<double>((e) => e.length.toDouble()), 0.0);
      expect(<String>[].sumBy<num>((e) => e.length), 0);
      expect(<String>[].sumBy<String>((e) => e, zero: ''), '');
      expect(() => <String>[].sumBy<String>((e) => e), throwsStateError);
    });
  });
}
