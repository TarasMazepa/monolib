import 'dart:async';
import 'package:monolib_dart/src/general/batcher.dart';
import 'package:test/test.dart';

void main() {
  group('Batcher', () {
    test('emits batch when maxBatchSize is reached', () async {
      final List<List<int>> emittedBatches = <List<int>>[];
      final Batcher<int> batcher = Batcher<int>(
        maxBatchSize: 3,
        maxDuration: const Duration(days: 1),
        onBatch: (List<int> batch) {
          emittedBatches.add(batch);
        },
      );

      batcher.add(1);
      batcher.add(2);
      expect(emittedBatches, isEmpty);

      batcher.add(3);
      expect(emittedBatches, hasLength(1));
      expect(emittedBatches[0], equals(<int>[1, 2, 3]));

      batcher.add(4);
      expect(emittedBatches, hasLength(1));

      await batcher.dispose();
      expect(emittedBatches, hasLength(2));
      expect(emittedBatches[1], equals(<int>[4]));
    });

    test('emits batch when maxDuration is reached', () async {
      final List<List<int>> emittedBatches = <List<int>>[];
      final Batcher<int> batcher = Batcher<int>(
        maxBatchSize: 10,
        maxDuration: const Duration(milliseconds: 50),
        onBatch: (List<int> batch) {
          emittedBatches.add(batch);
        },
      );

      batcher.add(1);
      batcher.add(2);

      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(emittedBatches, isEmpty);

      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(emittedBatches, hasLength(1));
      expect(emittedBatches[0], equals(<int>[1, 2]));

      await batcher.dispose();
    });

    test('dispose cancels timer and emits remaining items', () async {
      final List<List<int>> emittedBatches = <List<int>>[];
      final Batcher<int> batcher = Batcher<int>(
        maxBatchSize: 10,
        maxDuration: const Duration(milliseconds: 500),
        onBatch: (List<int> batch) {
          emittedBatches.add(batch);
        },
      );

      batcher.add(1);
      batcher.add(2);

      await batcher.dispose();

      expect(emittedBatches, hasLength(1));
      expect(emittedBatches[0], equals(<int>[1, 2]));
    });

    test('empty buffer does not emit on dispose', () async {
      final List<List<int>> emittedBatches = <List<int>>[];
      final Batcher<int> batcher = Batcher<int>(
        maxBatchSize: 10,
        maxDuration: const Duration(milliseconds: 500),
        onBatch: (List<int> batch) {
          emittedBatches.add(batch);
        },
      );

      await batcher.dispose();

      expect(emittedBatches, isEmpty);
    });

    test('throws StateError when adding items after dispose', () async {
      final Batcher<int> batcher = Batcher<int>(
        maxBatchSize: 10,
        maxDuration: const Duration(milliseconds: 500),
        onBatch: (List<int> batch) {},
      );

      await batcher.dispose();

      expect(() => batcher.add(1), throwsStateError);
    });

    test('waits for async onBatch to finish when disposing', () async {
      final List<List<int>> emittedBatches = <List<int>>[];
      bool asyncOperationCompleted = false;
      final Batcher<int> batcher = Batcher<int>(
        maxBatchSize: 10,
        maxDuration: const Duration(milliseconds: 500),
        onBatch: (List<int> batch) async {
          await Future<void>.delayed(const Duration(milliseconds: 100));
          asyncOperationCompleted = true;
          emittedBatches.add(batch);
        },
      );

      batcher.add(1);
      batcher.add(2);

      expect(asyncOperationCompleted, isFalse);
      expect(emittedBatches, isEmpty);

      await batcher.dispose();

      expect(asyncOperationCompleted, isTrue);
      expect(emittedBatches, hasLength(1));
      expect(emittedBatches[0], equals(<int>[1, 2]));
    });

    test('dispose waits for all in-flight batches to finish', () async {
      int completedBatches = 0;
      final Batcher<int> batcher = Batcher<int>(
        maxBatchSize: 2,
        maxDuration: const Duration(milliseconds: 500),
        onBatch: (List<int> batch) async {
          await Future<void>.delayed(const Duration(milliseconds: 100));
          completedBatches++;
        },
      );

      batcher.add(1);
      batcher.add(2); // Triggers first batch (in-flight)
      batcher.add(3); // Buffers second item

      expect(completedBatches, 0);

      // Dispose will flush the buffer [3] and wait for both [1, 2] and [3] to finish.
      await batcher.dispose();

      expect(completedBatches, 2);
    });
  });
}
