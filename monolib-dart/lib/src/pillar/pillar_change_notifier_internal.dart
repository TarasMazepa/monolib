import 'pillar_change_notifier.dart';

class PillarChangeNotifierInternal extends PillarChangeNotifier {
  void notify() {
    notifyListeners();
  }
}
