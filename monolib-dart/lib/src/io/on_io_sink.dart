/// Provides an extension on [IOSink] to guarantee safe resource teardown.
///
/// This library ensures that sinks used for asynchronous data streams, file
/// writing, or network transmission are automatically closed after
/// a scoped execution block, preventing memory leaks or zombie file handles.
library;

import 'dart:io';

/// Extends [IOSink] with resource-safe execution scopes.
///
/// Architecturally, this extension eliminates the boilerplate of manual
/// `try`/`finally` blocks typically required when dealing with raw streams
/// or file outputs, guaranteeing that underlying resources are freed even
/// if the writing logic throws an exception.
extension OnIoSink on IOSink {
  /// Executes an asynchronous [call] within a managed [IOSink] lifecycle.
  ///
  /// This method safely unwraps and delegates to the provided [call] callback,
  /// supplying it with the current [IOSink] instance. After the [call] completes,
  /// either successfully or by throwing an error, this method guarantees that
  /// `close()` is awaited on the sink. This is critical for
  /// preventing zombie file handles and ensuring all buffered data is written
  /// to the underlying platform before the surrounding logic proceeds.
  ///
  /// The [call] parameter receives the current [IOSink] to perform write operations.
  /// Returns the generic type [T] produced by the [call].
  ///
  /// ```dart
  /// final file = File('data.txt');
  /// await file.openWrite().withIOSink((sink) async {
  ///   sink.writeln('First line');
  ///   // Sink is automatically closed when this block ends.
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
