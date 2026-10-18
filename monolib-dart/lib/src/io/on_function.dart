import 'dart:io';

/// Extension on `IOSink Function()` that provides scoped lifecycle management
/// for dynamically created [IOSink] instances.
extension OnFunction on IOSink Function() {
  /// Invokes this factory to acquire an [IOSink], executes [call] with it, and
  /// guarantees that [IOSink.close] is awaited in a `finally` block.
  ///
  /// - [call]: The asynchronous operation to perform using the acquired
  ///   [IOSink].
  ///
  /// Example:
  /// ```dart
  /// final file = File('data.csv');
  /// await (() => file.openWrite()).withIOSink((sink) async {
  ///   sink.writeln('header1,header2');
  ///   sink.writeln('value1,value2');
  /// });
  /// ```
  Future<void> withIOSink(Future<void> Function(IOSink) call) async {
    final ioSink = this();
    try {
      await call(ioSink);
    } finally {
      await ioSink.close();
    }
  }
}
