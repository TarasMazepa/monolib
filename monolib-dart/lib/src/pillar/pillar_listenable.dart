/// An interface for objects that can be listened to for state or scope changes.
///
/// This provides a pure-Dart notification contract (analogous to Flutter's
/// `Listenable`) without requiring a dependency on Flutter.
///
/// Callers typically encounter this as the return type of `Pillar.changeNotifierFor`,
/// and implementations can use `PillarChangeNotifier` rather than implementing
/// this interface directly. In Flutter applications, instances can be adapted
/// using the `.asListenable` extension from `package:monolib_flutter`.
///
/// Example:
/// ```dart
/// final PillarListenable listenable = pillar.changeNotifierFor(myScope);
///
/// void onScopeChanged() {
///   print('Scope updated!');
/// }
///
/// listenable.addListener(onScopeChanged);
/// // Later:
/// listenable.removeListener(onScopeChanged);
/// ```
abstract class PillarListenable {
  /// Registers a [listener] callback to be invoked when the object changes.
  ///
  /// The [listener] is called without any arguments. If the exact same
  /// [listener] is added multiple times, it may be called multiple times
  /// depending on the implementation.
  void addListener(void Function() listener);

  /// Unregisters a previously registered [listener] callback.
  ///
  /// If the [listener] was not previously added, this method should have
  /// no effect. If the [listener] was added multiple times, this method
  /// typically removes only one instance of it, but behavior may vary by
  /// implementation.
  void removeListener(void Function() listener);
}
