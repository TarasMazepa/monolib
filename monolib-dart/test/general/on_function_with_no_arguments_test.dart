import 'package:monolib_dart/monolib_dart.dart';
import 'package:test/test.dart';

void main() {
  group('OnFunctionWithNoArguments', () {
    test('callWithRetryOnFailure succeeds first try', () {
      int callCount = 0;
      int myFunc() {
        callCount++;
        return 42;
      }

      final result = myFunc.callWithRetryOnFailure(times: 3);
      expect(result, 42);
      expect(callCount, 1);
    });

    test('callWithRetryOnFailure succeeds second try', () {
      int callCount = 0;
      int myFunc() {
        callCount++;
        if (callCount == 1) throw Exception('fail');
        return 42;
      }

      final result = myFunc.callWithRetryOnFailure(times: 3);
      expect(result, 42);
      expect(callCount, 2);
    });

    test('callWithRetryOnFailure fails all tries', () {
      int callCount = 0;
      int myFunc() {
        callCount++;
        throw Exception('fail $callCount');
      }

      expect(() => myFunc.callWithRetryOnFailure(times: 3), throwsException);
      expect(callCount, 3);
    });

    test('retryOnFailure wrapper', () {
      int callCount = 0;
      int myFunc() {
        callCount++;
        if (callCount < 3) throw Exception('fail');
        return 42;
      }

      final result = retryOnFailure(myFunc, times: 3);
      expect(result, 42);
      expect(callCount, 3);
    });
  });
}
