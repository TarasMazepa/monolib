import 'dart:async';

import 'package:monolib_openrouter/monolib_openrouter.dart';
import 'package:test/test.dart';

void main() {
  group('OnStream', () {
    test('timeoutAndClose passes through events emitted in time', () async {
      bool timedOut = false;

      final result = await Stream.fromIterable([1, 2, 3])
          .timeoutAndClose(
            timeLimit: const Duration(seconds: 1),
            onTimeout: () => timedOut = true,
          )
          .toList();

      expect(result, equals([1, 2, 3]));
      expect(timedOut, isFalse);
    });

    test('timeoutAndClose closes the stream and calls onTimeout', () async {
      bool timedOut = false;
      final controller = StreamController<int>();
      addTearDown(controller.close);
      controller.add(1);

      final result = await controller.stream
          .timeoutAndClose(
            timeLimit: const Duration(milliseconds: 10),
            onTimeout: () => timedOut = true,
          )
          .toList();

      expect(result, equals([1]));
      expect(timedOut, isTrue);
    });

    test('timeoutAndClose passes through errors', () async {
      final stream = Stream<int>.error(StateError('boom')).timeoutAndClose(
        timeLimit: const Duration(seconds: 1),
      );

      await expectLater(stream, emitsError(isA<StateError>()));
    });
  });
}
