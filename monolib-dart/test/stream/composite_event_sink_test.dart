import 'dart:async';
import 'package:monolib_dart/stream.dart';
import 'package:test/test.dart';

class MockEventSink<T> implements EventSink<T> {
  final List<T> addedData = [];
  final List<Object> addedErrors = [];
  bool isClosed = false;

  final Object? throwOnAdd;

  MockEventSink({this.throwOnAdd});

  @override
  void add(T data) {
    if (throwOnAdd != null) throw throwOnAdd!;
    addedData.add(data);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    addedErrors.add(error);
  }

  @override
  void close() {
    isClosed = true;
  }
}

void main() {
  group('CompositeEventSink', () {
    late MockEventSink<int> sink1;
    late MockEventSink<int> sink2;
    late CompositeEventSink<int> compositeSink;

    setUp(() {
      sink1 = MockEventSink<int>();
      sink2 = MockEventSink<int>();
      compositeSink = CompositeEventSink<int>([sink1, sink2]);
    });

    test('add() forwards data to all sinks', () {
      compositeSink.add(1);
      compositeSink.add(2);

      expect(sink1.addedData, equals([1, 2]));
      expect(sink2.addedData, equals([1, 2]));
    });

    test('addError() forwards errors to all sinks', () {
      final error1 = Exception('error1');
      final error2 = Exception('error2');

      compositeSink.addError(error1);
      compositeSink.addError(error2);

      expect(sink1.addedErrors, equals([error1, error2]));
      expect(sink2.addedErrors, equals([error1, error2]));
    });

    test('close() closes all sinks', () {
      expect(sink1.isClosed, isFalse);
      expect(sink2.isClosed, isFalse);

      compositeSink.close();

      expect(sink1.isClosed, isTrue);
      expect(sink2.isClosed, isTrue);
    });

    test('ignores operations after close()', () {
      compositeSink.close();

      compositeSink.add(1);
      final error = Exception('error');
      compositeSink.addError(error);

      // Sinks were closed, but no data/error was added
      expect(sink1.isClosed, isTrue);
      expect(sink1.addedData, isEmpty);
      expect(sink1.addedErrors, isEmpty);

      expect(sink2.isClosed, isTrue);
      expect(sink2.addedData, isEmpty);
      expect(sink2.addedErrors, isEmpty);
    });

    test('Strict Closure: throws StateError if throwOnClosed is true', () {
      final strictSink =
          CompositeEventSink<int>([sink1, sink2], throwOnClosed: true);
      strictSink.close();

      expect(() => strictSink.add(1), throwsA(isA<StateError>()));
      expect(
          () => strictSink.addError(Exception()), throwsA(isA<StateError>()));
      expect(() => strictSink.close(), throwsA(isA<StateError>()));
    });

    test(
        'Swallow Strategy: allows subsequent sinks to function when a previous one throws',
        () {
      final throwingSink =
          MockEventSink<int>(throwOnAdd: Exception('Sink1 error'));
      final goodSink = MockEventSink<int>();

      final swallowSink = CompositeEventSink<int>(
        [throwingSink, goodSink],
        exceptionStrategy: ExceptionStrategy.swallow,
      );

      swallowSink.add(1);

      expect(goodSink.addedData, equals([1]));
      expect(throwingSink.addedData, isEmpty);
    });

    test(
        'Aggregate Strategy: collects all exceptions and throws CompositeSinkError',
        () {
      final error1 = Exception('Sink1 error');
      final error2 = Exception('Sink2 error');
      final throwingSink1 = MockEventSink<int>(throwOnAdd: error1);
      final throwingSink2 = MockEventSink<int>(throwOnAdd: error2);

      final aggregateSink = CompositeEventSink<int>(
        [throwingSink1, throwingSink2],
        exceptionStrategy: ExceptionStrategy.aggregate,
      );

      try {
        aggregateSink.add(1);
        fail('Should have thrown CompositeSinkError');
      } on CompositeSinkError catch (e) {
        expect(e.errors, hasLength(2));
        expect(e.errors, containsAll([error1, error2]));
      }
    });
  });
}
