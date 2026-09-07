import 'dart:async';

import 'package:monolib_dart/src/stream/future_event_sink_extension.dart';
import 'package:test/test.dart';

void main() {
  group('FutureEventSinkExtension', () {
    test('buffers events until future resolves and then delivers them',
        () async {
      final completer = Completer<EventSink<int>>();
      final futureSink = completer.future.unwrap();

      final resolvedController = StreamController<int>();
      final emittedValues = <int>[];
      resolvedController.stream.listen(emittedValues.add);

      futureSink.add(1);
      futureSink.add(2);

      await Future<void>.delayed(Duration.zero);
      expect(emittedValues, isEmpty);

      completer.complete(resolvedController.sink);
      await Future<void>.delayed(Duration.zero);

      expect(emittedValues, [1, 2]);

      futureSink.add(3);
      await Future<void>.delayed(Duration.zero);
      expect(emittedValues, [1, 2, 3]);
    });

    test('buffers errors until future resolves and then delivers them',
        () async {
      final completer = Completer<EventSink<int>>();
      final futureSink = completer.future.unwrap();

      final resolvedController = StreamController<int>();
      final emittedErrors = <Object>[];
      resolvedController.stream.listen(
        (_) {},
        onError: (Object error) {
          emittedErrors.add(error);
        },
      );

      futureSink.addError('error 1');

      await Future<void>.delayed(Duration.zero);
      expect(emittedErrors, isEmpty);

      completer.complete(resolvedController.sink);
      await Future<void>.delayed(Duration.zero);

      expect(emittedErrors, ['error 1']);

      futureSink.addError('error 2');
      await Future<void>.delayed(Duration.zero);
      expect(emittedErrors, ['error 1', 'error 2']);
    });

    test('buffers close until future resolves and then calls it', () async {
      final completer = Completer<EventSink<int>>();
      final futureSink = completer.future.unwrap();

      final resolvedController = StreamController<int>();
      var isDone = false;
      resolvedController.stream.listen(
        (_) {},
        onDone: () {
          isDone = true;
        },
      );

      futureSink.close();

      await Future<void>.delayed(Duration.zero);
      expect(isDone, isFalse);

      completer.complete(resolvedController.sink);
      await Future<void>.delayed(Duration.zero);

      expect(isDone, isTrue);
    });

    test('handles future failure by closing sink and throwing uncaught error',
        () async {
      final expectedError = Exception('future failed');
      Object? uncaughtError;
      final completerDone = Completer<void>();

      runZonedGuarded(
        () {
          final completer = Completer<EventSink<int>>();
          final futureSink = completer.future.unwrap();

          futureSink.add(1); // Should be dropped

          completer.completeError(expectedError);
        },
        (error, stack) {
          uncaughtError = error;
          completerDone.complete();
        },
      );

      await completerDone.future.timeout(const Duration(milliseconds: 100));

      expect(uncaughtError, equals(expectedError));
    });
  });
}
