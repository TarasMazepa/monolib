/// Contains the internal implementation of the change notifier for the Pillar framework.
///
/// This file defines the `PillarChangeNotifierInternal` class which extends the
/// public `PillarChangeNotifier`. It is an internal bridge used by the `Pillar`
/// container to trigger reactive invalidations without exposing the `notify()`
/// mechanism to external consumers.
library;

import 'package:monolib_dart/src/pillar/pillar_change_notifier.dart';

/// An internal event dispatcher used by the [Pillar] container.
///
/// This class extends [PillarChangeNotifier] to expose a private [notify] method.
/// By keeping [notify] hidden from the public [PillarListenable] interface, the
/// architecture ensures that only the DI container itself (e.g., during [Pillar.replace])
/// can trigger scope invalidation broadcasts, while consumers can only listen
/// to them.
class PillarChangeNotifierInternal extends PillarChangeNotifier {
  /// Triggers a synchronous broadcast to all registered listeners.
  ///
  /// This method bridges the internal container events to the underlying
  /// [PillarChangeNotifier.notifyListeners] implementation.
  void notify() {
    notifyListeners();
  }
}
