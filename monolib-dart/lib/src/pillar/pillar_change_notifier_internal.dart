import 'package:monolib_dart/src/pillar/pillar_change_notifier.dart';

/// A private structural specialization of [PillarChangeNotifier] utilized by the
/// [Pillar] container itself.
///
/// It exposes an internal [notify] method specifically tailored for the framework
/// to trigger reactive updates when a scope is fundamentally altered (e.g., via
/// `Pillar.replace`).
class PillarChangeNotifierInternal extends PillarChangeNotifier {
  void notify() {
    notifyListeners();
  }
}
