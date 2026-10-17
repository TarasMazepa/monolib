/// Provides extension methods to bridge the pure Dart [PillarListenable] API
/// with Flutter's reactive ecosystem.
library;

import 'package:flutter/foundation.dart';
import 'package:monolib_dart/pillar.dart';
import 'package:monolib_flutter/src/pillar/pillar_listenable_adapter.dart';

/// Provides architectural bridging utilities that integrate the Pillar dependency injection
/// framework's pure Dart reactivity model with Flutter's native widget lifecycle.
///
/// Within the Pillar framework, lifecycle boundaries and state broadcasts are managed
/// via [PillarListenable] (found in `monolib-dart`), intentionally decoupling core business logic
/// from Flutter dependencies. This extension facilitates safe, cross-package adaptation by
/// allowing any [PillarListenable] (e.g., those returned by `Pillar.changeNotifierFor`)
/// to be efficiently converted into a standard Flutter [Listenable].
///
/// Architecturally, this enables native Flutter UI components (like `ListenableBuilder` or
/// `AnimatedBuilder`) to seamlessly react to Pillar scope state mutations without leaking
/// Flutter imports into the domain layer.
extension OnPillarListenable on PillarListenable {
  /// Adapts this pure Dart [PillarListenable] into a native Flutter [Listenable].
  ///
  /// This getter instantiates a [PillarListenableAdapter] that wraps the current instance.
  /// It translates Pillar's internal listener management into native Flutter [VoidCallback]
  /// notifications. This adapter pattern is structurally required to safely inject and consume
  /// pure Dart scope updates within a Flutter widget tree without manual lifecycle management.
  ///
  /// Example:
  /// ```dart
  /// // Within a Flutter Widget's build method:
  /// final scopeNotifier = pillar.changeNotifierFor(myScope);
  ///
  /// return ListenableBuilder(
  ///   listenable: scopeNotifier.asListenable, // Adapts the PillarListenable
  ///   builder: (context, child) {
  ///     return const Text('Pillar scope state has been updated!');
  ///   },
  /// );
  /// ```
  ///
  /// Returns a new [Listenable] proxy that safely delegates all subscriber registrations
  /// to the underlying [PillarListenable].
  Listenable get asListenable => PillarListenableAdapter(this);
}
