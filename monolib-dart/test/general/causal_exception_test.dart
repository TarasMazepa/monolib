import 'package:monolib_dart/monolib_dart.dart';
import 'package:test/test.dart';

void main() {
  group('CausalException', () {
    test('defaults optional fields and formats toString with message only', () {
      const exception = CausalException('something failed');

      expect(exception, isA<Exception>());
      expect(exception.message, 'something failed');
      expect(exception.cause, isNull);
      expect(exception.causeStackTrace, isNull);
      expect(exception.suppressed, isEmpty);
      expect(exception.toString(), 'CausalException: something failed');
    });

    test('stores message, cause, causeStackTrace, and suppressed', () {
      final cause = StateError('root');
      final stackTrace = StackTrace.current;
      final suppressed1 = FormatException('cleanup 1');
      final suppressed2 = Exception('cleanup 2');

      final exception = CausalException(
        'operation failed',
        cause: cause,
        causeStackTrace: stackTrace,
        suppressed: [suppressed1, suppressed2],
      );

      expect(exception.message, 'operation failed');
      expect(exception.cause, same(cause));
      expect(exception.causeStackTrace, same(stackTrace));
      expect(exception.suppressed, equals([suppressed1, suppressed2]));
      expect(
        exception.toString(),
        'CausalException: operation failed '
        '(caused by: Bad state: root) [2 suppressed]',
      );
    });

    test('formats toString cleanly when only some optional fields are set', () {
      final withCause = CausalException('failed', cause: 'oops');
      expect(withCause.toString(), 'CausalException: failed (caused by: oops)');

      const withSuppressed = CausalException('failed', suppressed: ['e1']);
      expect(
          withSuppressed.toString(), 'CausalException: failed [1 suppressed]');
    });

    test('throwNew creates and throws CausalException', () {
      final cause = ArgumentError('bad arg');
      final stackTrace = StackTrace.current;

      expect(
        () => CausalException.throwNew(
          'boom',
          cause: cause,
          causeStackTrace: stackTrace,
          suppressed: ['s1'],
        ),
        throwsA(
          isA<CausalException>()
              .having((e) => e.message, 'message', 'boom')
              .having((e) => e.cause, 'cause', same(cause))
              .having(
                (e) => e.causeStackTrace,
                'causeStackTrace',
                same(stackTrace),
              )
              .having((e) => e.suppressed, 'suppressed', ['s1']),
        ),
      );
    });
  });
}
