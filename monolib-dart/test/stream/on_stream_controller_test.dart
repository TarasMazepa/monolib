import 'dart:async';
import 'package:monolib_dart/stream.dart';
import 'package:test/test.dart';

class ThrowingController<T> implements StreamController<T> {
  @override
  bool get isClosed => false;

  @override
  void add(T event) {
    throw Exception('Error adding event');
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    throw Exception('Error adding error');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('OnStreamController', () {
    test('tryAdd adds an event when not closed', () async {
      final controller = StreamController<int>();
      final events = <int>[];
      controller.stream.listen(events.add);

      controller.tryAdd(1);
      controller.tryAdd(2);
      await Future.delayed(Duration.zero);
      await controller.close();

      expect(events, equals([1, 2]));
    });

    test('tryAddError adds an error when not closed', () async {
      final controller = StreamController<int>();
      final errors = <Object>[];
      controller.stream.listen((_) {}, onError: (e) {
        errors.add(e);
      });

      controller.tryAddError('error 1');
      controller.tryAddError('error 2');
      await Future.delayed(Duration.zero);
      await controller.close();

      expect(errors, equals(['error 1', 'error 2']));
    });

    test('tryAdd ignores event when closed', () async {
      final controller = StreamController<int>();
      final events = <int>[];
      controller.stream.listen(events.add);

      controller.tryAdd(1);
      await controller.close();
      controller.tryAdd(2);

      expect(events, equals([1]));
    });

    test('tryAddError ignores error when closed', () async {
      final controller = StreamController<int>();
      final errors = <Object>[];
      controller.stream.listen((_) {}, onError: (e) {
        errors.add(e);
      });

      controller.tryAddError('error 1');
      await controller.close();
      controller.tryAddError('error 2');

      expect(errors, equals(['error 1']));
    });

    test('tryAdd catches exceptions when ignoreError is true', () {
      final controller = ThrowingController<int>();
      expect(() => controller.tryAdd(1, ignoreError: true), returnsNormally);
    });

    test('tryAdd throws exceptions when ignoreError is false', () {
      final controller = ThrowingController<int>();
      expect(() => controller.tryAdd(1, ignoreError: false), throwsException);
      expect(() => controller.tryAdd(1), throwsException);
    });

    test('tryAddError catches exceptions when ignoreError is true', () {
      final controller = ThrowingController<int>();
      expect(() => controller.tryAddError(Exception(), ignoreError: true),
          returnsNormally);
    });

    test('tryAddError throws exceptions when ignoreError is false', () {
      final controller = ThrowingController<int>();
      expect(() => controller.tryAddError(Exception(), ignoreError: false),
          throwsException);
      expect(() => controller.tryAddError(Exception()), throwsException);
    });
  });
}
