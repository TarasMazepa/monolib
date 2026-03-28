import 'package:flutter/foundation.dart';
import 'package:monolib_dart/pillar.dart';

class PillarListenableAdapter implements Listenable {
  final PillarListenable pillarListenable;

  const PillarListenableAdapter(this.pillarListenable);

  @override
  void addListener(VoidCallback listener) {
    pillarListenable.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    pillarListenable.removeListener(listener);
  }
}
