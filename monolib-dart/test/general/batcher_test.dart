import 'dart:async';
import 'package:monolib_dart/src/general/batcher.dart';
import 'package:test/test.dart';

void main() {
  group('Batcher', () {
    test('emits batch when maxBatchSize is reached', () {
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

      batcher.dispose();
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

      batcher.dispose();
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

      batcher.dispose();

      expect(emittedBatches, hasLength(1));
      expect(emittedBatches[0], equals(<int>[1, 2]));
    });

    test('empty buffer does not emit on dispose', () {
      final List<List<int>> emittedBatches = <List<int>>[];
      final Batcher<int> batcher = Batcher<int>(
        maxBatchSize: 10,
        maxDuration: const Duration(milliseconds: 500),
        onBatch: (List<int> batch) {
          emittedBatches.add(batch);
        },
      );

      batcher.dispose();

      expect(emittedBatches, isEmpty);
    });
  });
}
