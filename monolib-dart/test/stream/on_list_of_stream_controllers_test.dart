import 'dart:async';
import 'dart:collection';
import 'package:monolib_dart/src/stream/on_list_of_stream_controllers.dart';
import 'package:test/test.dart';

// Create a custom list that throws on remove to test the error handlers
class ThrowingList<T> extends ListBase<T> {
  final List<T> _inner = [];

  @override
  int get length => _inner.length;

  @override
  set length(int newLength) => _inner.length = newLength;

  @override
  T operator [](int index) => _inner[index];

  @override
  void operator []=(int index, T value) => _inner[index] = value;

  @override
  void add(T element) => _inner.add(element);

  @override
  bool remove(Object? element) {
    throw Exception('Simulated remove error');
  }
}

void main() {
  group('OnListOfStreamControllers', () {
    test('addAndSetupOnCancel triggers onEmpty when last is removed', () async {
      bool onEmptyCalled = false;
      final controllers = <StreamController<int>>[];
      final controller = StreamController<int>();

      controllers.addAndSetupOnCancel(controller, onEmpty: () {
        onEmptyCalled = true;
      });

      // Manually trigger the callback for testing
      controller.onCancel?.call();

      expect(onEmptyCalled, isTrue);
      expect(controllers, isEmpty);
    });

    test('addAndSetupOnCancel onRemoveError with 1 argument', () async {
      final controllers = ThrowingList<StreamController<int>>();
      final controller = StreamController<int>();
      Object? caughtError;

      controllers.addAndSetupOnCancel(controller, onRemoveError: (Object e) {
        caughtError = e;
      });

      controller.onCancel?.call();
      expect(caughtError, isNotNull);
      expect(caughtError.toString(), contains('Simulated remove error'));
    });

    test('addAndSetupOnCancel onRemoveError with 2 arguments', () async {
      final controllers = ThrowingList<StreamController<int>>();
      final controller = StreamController<int>();
      Object? caughtError;
      StackTrace? caughtStackTrace;

      controllers.addAndSetupOnCancel(controller,
          onRemoveError: (Object e, StackTrace st) {
        caughtError = e;
        caughtStackTrace = st;
      });

      controller.onCancel?.call();
      expect(caughtError, isNotNull);
      expect(caughtStackTrace, isNotNull);
      expect(caughtError.toString(), contains('Simulated remove error'));
    });

    test('addAndSetupOnCancel allows onEmpty error to propagate', () async {
      final controllers = <StreamController<int>>[];
      final controller = StreamController<int>();

      controllers.addAndSetupOnCancel(controller, onEmpty: () {
        throw Exception('onEmpty error');
      });

      expect(() => controller.onCancel?.call(), throwsA(isA<Exception>()));
    });
  });
}
