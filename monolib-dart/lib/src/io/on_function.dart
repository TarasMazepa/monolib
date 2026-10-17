/// Architectural utility providing safe resource management and scoping for dynamically created [IOSink] instances.
///
/// This library ensures that short-lived IO operations do not leak file descriptors or leave asynchronous streams
/// unclosed in the event of upstream or execution errors, providing a safer alternative to manual resource lifecycle
/// management.
library;

import 'dart:io';

/// Bridges factory functions returning an [IOSink] into the scoped execution model.
///
/// This extension enables a safe lifecycle boundary, centralizing `try-finally` cleanup logic for dynamically instantiated
/// sinks. By applying [withIOSink] directly to an initialization closure, it removes the need for consumers to manually
/// track and close the sink, thus preventing resource leaks.
extension OnFunction on IOSink Function() {
  /// Safely executes the provided asynchronous [call] within the lifecycle bounds of the [IOSink] returned by this function.
  ///
  /// This method invokes the factory function to acquire an [IOSink], passes it to the provided [call],
  /// and guarantees that the sink is closed when the operation completes—regardless of whether
  /// [call] succeeds or throws an exception.
  ///
  /// This design ensures robust resource cleanup and avoids dangling file handles when writing streams or files.
  ///
  /// - [call]: The block of asynchronous operations to perform using the injected [IOSink].
  ///
  /// Returns a [Future] that completes when the [call] and the subsequent sink closure finish.
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
