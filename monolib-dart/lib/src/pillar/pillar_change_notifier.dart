import 'package:monolib_dart/src/pillar/pillar_listenable.dart';

/// The default, pure-Dart implementation of [PillarListenable] that powers reactive
/// state notifications within the Pillar dependency injection framework.
///
/// Architecturally, this class acts as a synchronous event multiplexer. It maintains a
/// registry of observer callbacks and dispatches notifications when changes occur
/// within a specific `PillarScope`. It serves as the foundation for cross-package
/// reactivity: while it exists in `monolib-dart` to remain decoupled from the UI,
/// Flutter applications dynamically bind it to the widget tree using `PillarListenableAdapter`
/// (typically via the `.asListenable()` extension).
///
/// Within the Pillar DI system, instances of this class are mapped 1:1 with a
/// dependency scope. Consumers rarely instantiate this class directly; instead,
/// they retrieve an active notifier using `Pillar.changeNotifierFor` to observe
/// when a scope's injected services are updated.
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
  /// The internal registry of active callback functions bound to this notifier.
  final List<void Function()> _listeners = [];

  /// Binds a reactive [listener] to this notifier's execution lifecycle.
  ///
  /// Whenever the underlying scope publishes an update via [notifyListeners],
  /// the provided [listener] callback is invoked synchronously. This mechanism enables
  /// UI components to automatically react when their injected dependencies change.
  ///
  /// If the identical [listener] closure is added multiple times, it will be invoked
  /// exactly that many times during a notification phase.
  @override
  void addListener(void Function() listener) {
    _listeners.add(listener);
  }

  /// Unbinds a previously registered [listener] from this notifier.
  ///
  /// Architecturally, this is crucial for preventing memory leaks when ephemeral UI
  /// components or transient controllers are destroyed. It removes the exact [listener]
  /// reference from the internal dispatch queue.
  ///
  /// If the [listener] was registered multiple times, this method only removes the
  /// first encountered instance. If the [listener] is absent from the registry, this
  /// method silently ignores the request.
  @override
  void removeListener(void Function() listener) {
    _listeners.remove(listener);
  }

  /// Synchronously broadcasts an update event to all registered listeners.
  ///
  /// This method iterates through the current dispatch queue and invokes every active
  /// callback without arguments. It safely utilizes a defensive shallow copy
  /// (`[..._listeners]`) before iteration. This prevents `ConcurrentModificationError`
  /// crashes if a listener dynamically calls [addListener] or [removeListener]
  /// during the active dispatch cycle.
  void notifyListeners() {
    for (final void Function() listener in [..._listeners]) {
      listener();
    }
  }

  /// Permanently tears down this notifier's active subscriptions.
  ///
  /// Architecturally, this method is invoked when the associated scope is destroyed
  /// or invalidated. It aggressively purges the underlying callback registry, instantly
  /// severing references to dependent elements and ensuring that memory leaks do not
  /// accumulate over the application's lifecycle.
  void dispose() {
    _listeners.clear();
  }
}
