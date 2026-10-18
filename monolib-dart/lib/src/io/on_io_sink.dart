import 'dart:io';

/// Extension on [IOSink] that provides scoped lifecycle management.
extension OnIoSink on IOSink {
  /// Executes [call] with this [IOSink] and guarantees that [close] is awaited
  /// in a `finally` block.
  ///
  /// - [call]: The asynchronous operation to perform using this [IOSink].
  ///
  /// Returns a [Future] resolving to the value of type [T] produced by [call].
  ///
  /// Example:
  /// ```dart
  /// final file = File('data.txt');
  /// await file.openWrite().withIOSink((sink) async {
  ///   sink.writeln('First line');
  /// });
  /// ```
  Future<T> withIOSink<T>(Future<T> Function(IOSink) call) async {
    try {
      return await call(this);
    } finally {
      await close();
    }
  }
}
