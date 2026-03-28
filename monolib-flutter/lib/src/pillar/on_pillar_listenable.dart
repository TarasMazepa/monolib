import 'package:flutter/foundation.dart';
import 'package:monolib_dart/pillar.dart';

import 'pillar_listenable_adapter.dart';

extension OnPillarListenable on PillarListenable {
  Listenable get asListenable => PillarListenableAdapter(this);
}
