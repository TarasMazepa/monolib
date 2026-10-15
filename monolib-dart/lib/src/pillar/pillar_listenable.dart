/// An interface for objects that can be listened to.
///
/// Classes that implement [PillarListenable] provide a way for observers to
/// register and unregister themselves to be notified of changes or events.
///
/// Example:
/// ```dart
/// class MyListenable implements PillarListenable {
///   final List<void Function()> _listeners = [];
///
///   @override
///   void addListener(void Function() listener) {
///     _listeners.add(listener);
///   }
///
///   @override
///   void removeListener(void Function() listener) {
///     _listeners.remove(listener);
///   }
///
///   void notify() {
///     for (final listener in _listeners) {
///       listener();
///     }
///   }
/// }
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
