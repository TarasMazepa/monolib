/// Provides the [Once] utility for ensuring functions or callbacks are executed
/// at most one time.
///
/// This is particularly useful in architectural components handling streams,
/// asynchronous resource cleanup, or callback-based events where duplicated
/// invocations would lead to exceptions or unintended side effects.
library;

/// A stateful utility designed to guarantee that a specific block of code or
/// callback is executed at most once, acting as a lightweight idempotent wrapper.
///
/// Within the repository architecture, [Once] is frequently utilized to manage
/// terminal operations (such as closing stream sinks or disposing resources)
/// where subsequent calls might throw exceptions (e.g., `StateError` on closed sinks),
/// or to prevent duplicate lifecycle initializations.
class Once {
  /// Indicates whether the encapsulated action has already been triggered.
  ///
  /// This field is mutated synchronously the first time [attempt] or a [wrap]ped
  /// function is invoked, and remains `true` for the lifecycle of this [Once] instance.
  bool executed = false;

  /// Conditionally executes the provided [call] back only if no prior invocations
  /// have been made on this [Once] instance.
  ///
  /// If [executed] is already `true`, this method immediately returns without
  /// invoking [call].
  ///
  /// ```dart
  /// final cleanup = Once();
  ///
  /// // Only the first call to attempt will execute the provided closure.
  /// cleanup.attempt(() => print('Cleaning up resources...')); // Prints
  /// cleanup.attempt(() => print('Cleaning up resources...')); // Ignored
  /// ```
  void attempt(void Function() call) {
    if (executed) return;
    executed = true;
    call();
  }

  /// Returns a new function that safely delegates to the provided [call] while
  /// automatically enforcing the at-most-once execution policy.
  ///
  /// This is particularly useful when passing callbacks to external APIs (such as
  /// event listeners or error handlers) where you lack direct control over how
  /// many times the callback might be triggered.
  ///
  /// ```dart
  /// final notifyComplete = Once();
  /// final safeCallback = notifyComplete.wrap(() => print('Process finished!'));
  ///
  /// someEventStream.listen((_) => safeCallback());
  /// // The print will only occur on the first event.
  /// ```
  void Function() wrap(void Function() call) {
    return () => attempt(call);
  }
}
