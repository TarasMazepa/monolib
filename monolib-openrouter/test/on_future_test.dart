import 'dart:async';

import 'package:monolib_openrouter/monolib_openrouter.dart';
import 'package:test/test.dart';

void main() {
  group('OnFuture', () {
    test('timeoutAsStream emits the value when completed in time', () async {
      bool timedOut = false;

      final result = await Future.value(1)
          .timeoutAsStream(
            timeLimit: const Duration(seconds: 1),
            onTimeout: () => timedOut = true,
          )
          .toList();

      expect(result, equals([1]));
      expect(timedOut, isFalse);
    });

    test('timeoutAsStream closes empty and calls onTimeout', () async {
      bool timedOut = false;

      final result = await Completer<int>()
          .future
          .timeoutAsStream(
            timeLimit: const Duration(milliseconds: 10),
            onTimeout: () => timedOut = true,
          )
          .toList();

      expect(result, isEmpty);
      expect(timedOut, isTrue);
    });

    test('timeoutAsStream emits errors of the future', () async {
      final stream = Future<int>.delayed(
        Duration.zero,
        () => throw StateError('boom'),
      ).timeoutAsStream(timeLimit: const Duration(seconds: 1));

      await expectLater(stream, emitsError(isA<StateError>()));
    });
  });
}
