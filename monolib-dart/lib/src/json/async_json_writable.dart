/// A callback passed into [AsyncJsonWritable.writeJsonAsync] that allows an
/// object to recursively serialize nested values back into the active
/// `jsonEncodeAsync` context.
///
/// When called with an [object], this function encodes it using the same
/// asynchronous rules and formatting as the root `jsonEncodeAsync` invocation,
/// appending the resulting JSON chunks to the active [StringSink].
typedef JsonEncoderCallback = Future<void> Function(Object? object);

/// A contract for objects that write their JSON representation directly to a
/// [StringSink] during `jsonEncodeAsync`.
///
/// Implementing [AsyncJsonWritable] bypasses standard `toJson()` serialization
/// and grants direct access to the target [StringSink]. This allows large or
/// streaming payloads (such as `StreamingJsonString`) to be written
/// progressively without buffering the entire structure in memory.
///
/// Example:
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
abstract class AsyncJsonWritable {
  /// Writes the raw JSON representation of this object directly to [sink].
  ///
  /// Implementers are responsible for emitting valid JSON syntax (such as
  /// surrounding quotes for strings or brackets for arrays and objects). Nested
  /// values can be serialized recursively into [sink] using [encode].
  Future<void> writeJsonAsync(StringSink sink, JsonEncoderCallback encode);
}
