import 'package:monolib_dart/src/pillar/pillar_listenable.dart';

/// A pure Dart implementation of an observable state emitter, mirroring the
/// architectural intent of Flutter's `ChangeNotifier`.
///
/// Classes managing reactive state in `monolib-dart` can extend or mix in
/// [PillarChangeNotifier] to alert external observers of mutations. Observers
/// register callback delegates via [addListener].
class PillarChangeNotifier implements PillarListenable {
  final List<void Function()> _listeners = [];

  @override
  void addListener(void Function() listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(void Function() listener) {
    _listeners.remove(listener);
  }

  /// Synchronously broadcasts an update by invoking all currently registered
  /// listeners. The listener list is shallow-copied during iteration to protect
  /// against concurrent modifications (e.g., a listener removing itself during
  /// the notification cycle).
  void notifyListeners() {
    for (final void Function() listener in [..._listeners]) {
      listener();
    }
  }

  /// Clears all active listeners. This should be explicitly invoked when the
  /// reactive component reaches the end of its lifecycle to prevent memory leaks.
  void dispose() {
    _listeners.clear();
  }
}
