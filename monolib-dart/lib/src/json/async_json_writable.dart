/// A callback that allows an [AsyncJsonWritable] to recursively encode its children.
typedef JsonEncoderCallback = Future<void> Function(Object? object);

/// An interface for objects that need fine-grained, asynchronous control
/// over how they are written to a JSON sink.
abstract interface class AsyncJsonWritable {
  /// Writes the JSON representation of this object directly to the [sink].
  /// Use [encode] to safely serialize any nested child objects.
  Future<void> writeJsonAsync(StringSink sink, JsonEncoderCallback encode);
}
