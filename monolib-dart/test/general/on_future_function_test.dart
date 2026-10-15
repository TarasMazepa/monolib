import 'package:monolib_dart/monolib_dart.dart';
import 'package:test/test.dart';

void main() {
  group('OnFutureFunction', () {
    test('asyncCallWithRetryOnFailure succeeds first try', () async {
      int attempts = 0;
      Future<int> call() async {
        attempts++;
        return 42;
      }

      final result = await call.asyncCallWithRetryOnFailure(times: 3);
      expect(result, 42);
      expect(attempts, 1);
    });

    test('asyncCallWithRetryOnFailure succeeds second try', () async {
      int attempts = 0;
      Future<int> call() async {
        attempts++;
        if (attempts == 1) {
          throw Exception('Failed on first try');
        }
        return 42;
      }

      final result = await call.asyncCallWithRetryOnFailure(times: 3);
      expect(result, 42);
      expect(attempts, 2);
    });

    test('asyncCallWithRetryOnFailure fails all tries', () async {
      int attempts = 0;
      Future<int> call() async {
        attempts++;
        throw Exception('Attempt $attempts failed');
      }

      await expectLater(
        call.asyncCallWithRetryOnFailure(times: 3),
        throwsA(isA<Exception>().having(
            (e) => e.toString(), 'message', 'Exception: Attempt 1 failed')),
      );
      expect(attempts, 3);
    });

    test('asyncRetryOnFailure wrapper', () async {
      int attempts = 0;
      Future<int> call() async {
        attempts++;
        if (attempts < 3) {
          throw Exception('Failed');
        }
        return 42;
      }

      final result = await asyncRetryOnFailure(call, times: 3);
      expect(result, 42);
      expect(attempts, 3);
    });

    test('throws ArgumentError if times is <= 0', () async {
      Future<int> call() async => 42;

      await expectLater(
        call.asyncCallWithRetryOnFailure(times: 0),
        throwsA(isA<ArgumentError>()
            .having((e) => e.message, 'message', 'must be greater than 0')),
      );

      await expectLater(
        call.asyncCallWithRetryOnFailure(times: -1),
        throwsA(isA<ArgumentError>()
            .having((e) => e.message, 'message', 'must be greater than 0')),
      );
    });
  });
}
