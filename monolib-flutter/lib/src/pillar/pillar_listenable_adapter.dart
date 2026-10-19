import 'package:flutter/foundation.dart';
import 'package:monolib_dart/pillar.dart';

/// Internal [Listenable] adapter that wraps a pure Dart [PillarListenable].
class PillarListenableAdapter implements Listenable {
  final PillarListenable _pillarListenable;

  /// Creates a [PillarListenableAdapter] wrapping [pillarListenable].
  const PillarListenableAdapter(PillarListenable pillarListenable)
      : _pillarListenable = pillarListenable;

  @override
  void addListener(VoidCallback listener) {
    _pillarListenable.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _pillarListenable.removeListener(listener);
  }
}
