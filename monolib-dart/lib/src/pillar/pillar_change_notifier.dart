import 'pillar_listenable.dart';

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

  void notifyListeners() {
    for (final void Function() listener in _listeners) {
      listener();
    }
  }

  void dispose() {
    _listeners.clear();
  }
}
