import 'package:monolib_dart/src/pillar/pillar_listenable.dart';

/// A pure-Dart implementation of [PillarListenable] that dispatches synchronous
/// notifications when a `PillarScope` is updated.
///
/// Each notifier maintains a list of listener callbacks and is typically
/// obtained via `Pillar.changeNotifierFor` to observe when dependencies in a
/// scope are replaced. In Flutter applications, it can be adapted to a Flutter
/// `Listenable` using `PillarListenableAdapter` (via the `.asListenable`
/// extension getter).
///
/// Example:
/// ```dart
/// final PillarListenable scopeNotifier = pillar.changeNotifierFor(myScope);
///
/// void onDependenciesUpdated() {
///   print('The DI scope has been invalidated or updated!');
/// }
///
/// scopeNotifier.addListener(onDependenciesUpdated);
/// ```
class PillarChangeNotifier implements PillarListenable {
  /// The registered listener callbacks.
  final List<void Function()> _listeners = [];

  /// Registers [listener] to be called synchronously whenever [notifyListeners]
  /// is invoked.
  ///
  /// If the same [listener] is added multiple times, it will be called once for
  /// each registration during a notification pass.
  @override
  void addListener(void Function() listener) {
    _listeners.add(listener);
  }

  /// Removes a previously registered [listener] from this notifier.
  ///
  /// If [listener] was registered multiple times, only the first matching
  /// entry is removed. Does nothing if [listener] is not registered.
  @override
  void removeListener(void Function() listener) {
    _listeners.remove(listener);
  }

  /// Synchronously invokes all registered listeners.
  ///
  /// Iterates over a shallow copy of the listener list so that listeners may
  /// safely call [addListener] or [removeListener] during dispatch without
  /// causing a [ConcurrentModificationError].
  void notifyListeners() {
    for (final void Function() listener in [..._listeners]) {
      listener();
    }
  }

  /// Clears all registered listeners from this notifier.
  void dispose() {
    _listeners.clear();
  }
}
