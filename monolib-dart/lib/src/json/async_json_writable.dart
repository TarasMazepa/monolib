/// Provides the [AsyncJsonWritable] interface for enabling inversion-of-control
/// during asynchronous JSON encoding.
///
/// This library is a core piece of the `jsonEncodeAsync` architecture, allowing
/// custom objects to dictate their own chunked, unbuffered serialization logic
/// rather than relying on synchronous, in-memory `toJson()` maps.
library;

/// A callback passed into [AsyncJsonWritable.writeJsonAsync] that allows the
/// implementing object to recursively serialize its nested children back into
/// the parent `jsonEncodeAsync` context.
///
/// When called with an [object], this function will encode it using the same
/// asynchronous rules and formatting as the root [jsonEncodeAsync] process,
/// appending the resulting string chunks to the active [StringSink].
typedef JsonEncoderCallback = Future<void> Function(Object? object);

/// An interface providing inversion-of-control for objects serialized via
/// [jsonEncodeAsync].
///
/// By implementing [AsyncJsonWritable], an object bypasses standard `toJson()`
/// serialization, gaining direct access to the underlying JSON [StringSink].
/// This architectural pattern enables massive, dynamic, or chunk-based
/// data sets (like streaming large strings or reading from file systems) to be
/// written out asynchronously without buffering the entire representation in
/// memory.
///
/// Real-world usage typically involves streaming classes like
/// [StreamingJsonString], which writes `Stream<String>` chunks progressively
/// to the sink.
///
/// ```dart
/// class MyLazyArray implements AsyncJsonWritable {
///   final Stream<int> _numbers;
///   MyLazyArray(this._numbers);
///
///   @override
///   Future<void> writeJsonAsync(StringSink sink, JsonEncoderCallback encode) async {
///     sink.write('[');
///     bool first = true;
///     await for (final number in _numbers) {
///       if (!first) sink.write(',');
///       await encode(number);
///       first = false;
///     }
///     sink.write(']');
///   }
/// }
/// ```
abstract interface class AsyncJsonWritable {
  /// Writes the raw JSON string representation of this object directly into
  /// the [sink].
  ///
  /// Implementers are entirely responsible for writing valid JSON syntax (e.g.,
  /// wrapping text in double quotes or formatting arrays/objects). If this
  /// object contains nested values, use the provided [encode] callback to
  /// safely and recursively serialize them into the active sink.
  Future<void> writeJsonAsync(StringSink sink, JsonEncoderCallback encode);
}
