/// A guard that ensures a callback is executed at most once.
///
/// Useful for idempotent lifecycle operations such as resource disposal or
/// one-time initialization.
///
/// Example:
/// ```dart
/// final cleanup = Once();
/// cleanup.attempt(() => print('Cleaning up...')); // Prints
/// cleanup.attempt(() => print('Cleaning up...')); // Ignored
/// ```
class Once {
  bool _executed = false;

  /// Whether an action has already been executed by this [Once] instance.
  ///
  /// Set to `true` synchronously on the first call to [attempt] or a function
  /// returned by [wrap].
  bool get executed => _executed;

  /// Executes [call] if this [Once] instance has not yet been triggered.
  ///
  /// If [executed] is already `true`, returns immediately without invoking
  /// [call].
  ///
  /// Example:
  /// ```dart
  /// final cleanup = Once();
  /// cleanup.attempt(() => print('Cleaning up resources...')); // Prints
  /// cleanup.attempt(() => print('Cleaning up resources...')); // Ignored
  /// ```
  void attempt(void Function() call) {
    if (_executed) return;
    _executed = true;
    call();
  }

  /// Returns a zero-argument function that invokes [call] at most once via
  /// [attempt].
  ///
  /// Example:
  /// ```dart
  /// final notifyComplete = Once();
  /// final safeCallback = notifyComplete.wrap(() => print('Process finished!'));
  ///
  /// safeCallback(); // Prints
  /// safeCallback(); // Ignored
  /// ```
  void Function() wrap(void Function() call) {
    return () => attempt(call);
  }
}
