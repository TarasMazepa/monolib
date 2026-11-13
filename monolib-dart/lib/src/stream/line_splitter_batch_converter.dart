import 'dart:convert';

import 'package:monolib_dart/src/common/batching_sink_mixin.dart';
import 'package:monolib_dart/src/common/chunked_only_converter.dart';
import 'package:monolib_dart/src/stream/line_splitter_converter.dart';

/// A streaming [Converter] adapter around Dart's [LineSplitter] that splits
/// incoming string chunks into lines and emits them in per-chunk batches
/// (`List<T>`).
///
/// [LineSplitterBatchConverter] extends [ChunkedOnlyConverter] and combines
/// [LineSplitter] with [BatchingSinkMixin]. Lines extracted by [LineSplitter]
/// during each incoming string chunk are optionally mapped using [mapper] (or
/// passed directly as [String] when [mapper] is omitted) and accumulated into a
/// `List<T>` batch. The batch is flushed at the end of each chunk, reducing
/// stream event overhead on high-volume line-based streams.
///
/// For one-by-one emission of lines, see [LineSplitterConverter].
///
/// Example:
/// ```dart
/// final fileStream = File('large_data.txt').openRead().transform(utf8.decoder);
///
/// final batchStream = fileStream.transform(
///   const LineSplitterBatchConverter<String>(),
/// );
///
/// await for (final batch in batchStream) {
///   await processLineBatch(batch);
/// }
/// ```
///
/// Example with mapping:
/// ```dart
/// final batchStream = fileStream.transform(
///   LineSplitterBatchConverter<int>.mapped((line) {
///     return int.tryParse(line);
///   }),
/// );
/// ```
class LineSplitterBatchConverter<T>
    extends ChunkedOnlyConverter<String, List<T>> {
  final T? Function(String line)? _mapper;
  final void Function(List<T> batch)? _onBatch;
  final void Function()? _onDone;

  /// Creates a [LineSplitterBatchConverter] that splits incoming string chunks
  /// into lines and emits them in batches.
  ///
  /// If [mapper] is provided, each parsed line is mapped to [T]; returning
  /// `null` skips the line. If omitted, lines are added directly (which
  /// requires [T] to be compatible with [String]).
  ///
  /// Optionally invokes [onBatch] before each batch is emitted and [onDone]
  /// when the input stream completes.
  const LineSplitterBatchConverter({
    T? Function(String line)? mapper,
    void Function(List<T> batch)? onBatch,
    void Function()? onDone,
  })  : _mapper = mapper,
        _onBatch = onBatch,
        _onDone = onDone;

  /// Creates a [LineSplitterBatchConverter] that maps parsed lines using
  /// [mapper] and emits non-null results in batches.
  ///
  /// Optionally invokes [onBatch] before each batch is emitted and [onDone]
  /// when the input stream completes.
  const LineSplitterBatchConverter.mapped(
    T? Function(String line) mapper, {
    void Function(List<T> batch)? onBatch,
    void Function()? onDone,
  })  : _mapper = mapper,
        _onBatch = onBatch,
        _onDone = onDone;

  /// Starts a chunked conversion that splits incoming string chunks into lines
  /// and emits non-empty `List<T>` batches to [sink].
  @override
  Sink<String> startChunkedConversion(Sink<List<T>> sink) {
    return _LineSplitterBatchConverterSink<T>(
      sink,
      mapper: _mapper,
      onBatch: _onBatch,
      onDone: _onDone,
    );
  }
}

/// An alias for [LineSplitterBatchConverter] emphasizing batch decoding semantics.
typedef LineSplitterBatchDecoder<T> = LineSplitterBatchConverter<T>;

/// An alias for [LineSplitterBatchConverter] emphasizing mapped batch decoding semantics.
typedef LineSplitterMappedBatchDecoder<T> = LineSplitterBatchConverter<T>;

/// Internal [ChunkedConversionSink] implementation for [LineSplitterBatchConverter].
class _LineSplitterBatchConverterSink<T>
    with BatchingSinkMixin<T>
    implements ChunkedConversionSink<String> {
  @override
  final Sink<List<T>> outSink;

  final T? Function(String line)? _mapper;
  final void Function(List<T> batch)? _onBatch;
  final void Function()? _onDone;

  late final Sink<String> _lineSplitterSink;

  /// Creates a sink that splits incoming string chunks using [LineSplitter],
  /// batches mapped non-null lines, and forwards each batch to [outSink].
  _LineSplitterBatchConverterSink(
    this.outSink, {
    T? Function(String line)? mapper,
    void Function(List<T> batch)? onBatch,
    void Function()? onDone,
  })  : _mapper = mapper,
        _onBatch = onBatch,
        _onDone = onDone {
    _lineSplitterSink = const LineSplitter().startChunkedConversion(
      _LineSplitterAccumulatorSink<T>(this),
    );
  }

  void _handleLine(String line) {
    if (_mapper != null) {
      final mapped = _mapper(line);
      if (mapped != null) {
        addToBatch(mapped);
      }
    } else {
      addToBatch(line as T);
    }
  }

  /// Ingests a raw string [chunk], splits complete lines, and flushes any
  /// accumulated batch items to [outSink] via [flushBatchOnChunkEnd].
  @override
  void add(String chunk) {
    _lineSplitterSink.add(chunk);
    flushBatchOnChunkEnd(onBatch: _onBatch);
  }

  /// Finalizes line parsing, flushes any trailing line batch, closes [outSink],
  /// and invokes [_onDone] if provided.
  @override
  void close() {
    _lineSplitterSink.close();
    flushBatchOnChunkEnd(onBatch: _onBatch);
    outSink.close();
    _onDone?.call();
  }
}

/// Internal helper sink that receives lines from [LineSplitter] and forwards
/// them to [_LineSplitterBatchConverterSink._handleLine].
class _LineSplitterAccumulatorSink<T> implements Sink<String> {
  final _LineSplitterBatchConverterSink<T> _sink;

  _LineSplitterAccumulatorSink(this._sink);

  @override
  void add(String data) => _sink._handleLine(data);

  @override
  void close() {}
}
