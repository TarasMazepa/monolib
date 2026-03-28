import 'package:monolib_dart/monolib_dart.dart';
import 'package:test/test.dart';

void main() {
  group('OnDouble', () {
    test('discardedByFloor', () {
      expect(1.5.discardedByFloor(), 0.5);
      expect(2.0.discardedByFloor(), 0.0);
      expect((-1.5).discardedByFloor(),
          0.5); // floor of -1.5 is -2.0, -1.5 - (-2.0) = 0.5
    });

    test('toFiveMoonRating', () {
      expect(0.0.toFiveMoonRating(), '🌑🌑🌑🌑🌑');
      expect(0.5.toFiveMoonRating(), '🌕🌕🌗🌑🌑');
      expect(1.0.toFiveMoonRating(), '🌕🌕🌕🌕🌕');
      expect(1.5.toFiveMoonRating(), '🌕🌕🌕🌕🌕');
      expect((-0.5).toFiveMoonRating(), '🌑🌑🌑🌑🌑');
    });
  });
}
