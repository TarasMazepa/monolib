import 'package:monolib_dart/src/pillar/pillar_change_notifier.dart';

class PillarChangeNotifierInternal extends PillarChangeNotifier {
  void notify() {
    notifyListeners();
  }
}
