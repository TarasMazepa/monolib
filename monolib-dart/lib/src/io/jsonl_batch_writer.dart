import 'dart:io';

import 'package:monolib_dart/jsonl.dart';
import 'package:monolib_dart/monolib_dart.dart';

/// A utility that combines [Batcher] and an [IOSink] to efficiently
/// write high-frequency data to a JSONL file in batches.
class JsonlBatchWriter<T> {
  final File _file;
  IOSink? _sink;
  late final Batcher<T> _batcher;

  /// Creates a [JsonlBatchWriter] that lazily appends to the provided [file].
  JsonlBatchWriter({
    required File file,
    int? maxBatchSize = 100,
    Duration? maxDuration = const Duration(milliseconds: 100),
    void Function(Object error, StackTrace stackTrace)? onError,
  }) : _file = file {
    _batcher = Batcher<T>(
      maxBatchSize: maxBatchSize,
      maxDuration: maxDuration,
      onBatch: (List<T> items) async {
        try {
          _sink ??= _file.openWrite(mode: FileMode.writeOnlyAppend);

          await jsonlEncodeAsync(items: items, sink: _sink!);
          await _sink!.flush();
        } catch (e, st) {
          if (onError != null) {
            onError(e, st);
          } else {
            stderr.writeln('JsonlBatchWriter error: $e\n$st');
          }
        }
      },
    );
  }

  /// Adds an item to the internal buffer to be written to the file.
  void add(T item) => _batcher.add(item);

  /// Flushes any pending items to disk and safely closes the file handle.
  Future<void> dispose() async {
    await _batcher.dispose();
    try {
      await _sink?.close();
    } catch (_) {
      // Ignore errors when closing, as they might stem from the sink
      // already failing during a write operation.
    }
  }
}
