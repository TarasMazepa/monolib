import 'package:monolib_dart/monolib_dart.dart';
import 'package:test/test.dart';

void main() {
  group('OnDouble', () {
    test('toFiveMoonRating', () {
      expect(0.0.toFiveMoonRating(), '🌑🌑🌑🌑🌑');
      expect(0.5.toFiveMoonRating(), '🌕🌕🌗🌑🌑');
      expect(1.0.toFiveMoonRating(), '🌕🌕🌕🌕🌕');
      expect(1.5.toFiveMoonRating(), '🌕🌕🌕🌕🌕');
      expect((-0.5).toFiveMoonRating(), '🌑🌑🌑🌑🌑');
    });
  });
}
